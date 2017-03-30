#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <cuda.h>
#include <cuda_runtime.h>

#ifdef _WIN32
#include <windows.h>
extern "C" void compat_usleep(uint64_t waitTime)
{
    if (waitTime > 0)
    {
        if (waitTime > 100)
        {
            // use a waitable timer for larger intervals > 0.1ms

            HANDLE timer;
            LARGE_INTEGER ft;

            ft.QuadPart = -(10*waitTime); // Convert to 100 nanosecond interval, negative value indicates relative time

            timer = CreateWaitableTimer(NULL, TRUE, NULL);
            SetWaitableTimer(timer, &ft, 0, NULL, NULL, 0);
            WaitForSingleObject(timer, INFINITE);
            CloseHandle(timer);
        }
        else
        {
            // use a polling loop for short intervals <= 100ms

            LARGE_INTEGER perfCnt, start, now;
            __int64 elapsed;

            QueryPerformanceFrequency(&perfCnt);
            QueryPerformanceCounter(&start);
            do {
		SwitchToThread();
                QueryPerformanceCounter((LARGE_INTEGER*) &now);
                elapsed = (__int64)((now.QuadPart - start.QuadPart) / (float)perfCnt.QuadPart * 1000 * 1000);
            } while ( elapsed < waitTime );
        }
    }
}
#else
#include <unistd.h>
extern "C" void compat_usleep(uint64_t waitTime)
{
	usleep(waitTime);
}
#endif

#include "cryptonight.h"
#include "cuda_extra.h"
#include "cuda_aes.hpp"
#include "cuda_device.hpp"

#ifdef XMRMINER_LARGEGRID
typedef uint64_t IndexType;
#else
typedef int IndexType;
#endif

__device__ __forceinline__ uint64_t cuda_mul128( uint64_t multiplier, uint64_t multiplicand, uint64_t* product_hi )
{
	*product_hi = __umul64hi( multiplier, multiplicand );
	return (multiplier * multiplicand );
}

template< typename T >
__device__ __forceinline__ T loadGlobal64( T * const addr )
{
	T x;
	asm volatile( "ld.global.cg.u64 %0, [%1];" : "=l"( x ) : "l"( addr ) );
	return x;
}

template< typename T >
__device__ __forceinline__ T loadGlobal32( T * const addr )
{
	T x;
	asm volatile( "ld.global.cg.u32 %0, [%1];" : "=r"( x ) : "l"( addr ) );
	return x;
}


template< typename T >
__device__ __forceinline__ void storeGlobal32( T* addr, T const & val )
{
	asm volatile( "st.global.cg.u32 [%0], %1;" : : "l"( addr ), "r"( val ) );
}

__global__ void cryptonight_core_gpu_phase1( int threads, int bfactor, int partidx, uint32_t * __restrict__ long_state, uint32_t * __restrict__ ctx_state, uint32_t * __restrict__ ctx_key1 )
{
	__shared__ uint32_t sharedMemory[1024];

	cn_aes_gpu_init( sharedMemory );
	__syncthreads( );

	const int thread = ( blockDim.x * blockIdx.x + threadIdx.x ) >> 3;
	const int sub = ( threadIdx.x & 7 ) << 2;

	const int batchsize = 0x80000 >> bfactor;
	const int start = partidx * batchsize;
	const int end = start + batchsize;

	if ( thread >= threads )
		return;

	uint32_t key[40], text[4];

	MEMCPY8( key, ctx_key1 + thread * 40, 20 );

	if( partidx == 0 )
	{
		// first round
		MEMCPY8( text, ctx_state + thread * 50 + sub + 16, 2 );
	}
	else
	{
		// load previous text data
		MEMCPY8( text, &long_state[( (uint64_t) thread << 19 ) + sub + start - 32], 2 );
	}
	__syncthreads( );
	for ( int i = start; i < end; i += 32 )
	{
		cn_aes_pseudo_round_mut( sharedMemory, text, key );
		MEMCPY8(&long_state[((uint64_t) thread << 19) + (sub + i)], text, 2);
	}
}

#ifdef XMR_THREADS
__launch_bounds__( XMRMINER_THREADS * 4 )
#endif
__global__ void cryptonight_core_gpu_phase2( int threads, int bfactor, int partidx, uint32_t * d_long_state, uint32_t * d_ctx_a, uint32_t * d_ctx_b )
{
	__shared__ uint32_t sharedMemory[1024];

	cn_aes_gpu_init( sharedMemory );

	__syncthreads( );

#if __CUDA_ARCH__ >= 300

	const int thread = ( blockDim.x * blockIdx.x + threadIdx.x ) >> 2;
	const int sub = threadIdx.x & 3;
	const int sub2 = sub & 2;

	if ( thread >= threads )
		return;

	int i, k, j;
	const int batchsize = ITER >> ( 2 + bfactor );
	const int start = partidx * batchsize;
	const int end = start + batchsize;
	uint32_t * long_state = &d_long_state[(IndexType) thread << 19];
	uint32_t * ctx_a = d_ctx_a + thread * 4;
	uint32_t * ctx_b = d_ctx_b + thread * 4;
	uint32_t a, d[2];
	uint32_t t1[2], t2[2], res;
	uint64_t reshi, reslo;

	a = ctx_a[sub];
	d[1] = ctx_b[sub];
	#pragma unroll 2
	for ( i = start; i < end; ++i )
	{
		#pragma unroll 2
		for ( int x = 0; x < 2; ++x )
		{

			j = ( ( ( __shfl( (int) a, 0, 4 ) & 0x1FFFF0 ) >> 2 ) + sub );

			const int x_0 = loadGlobal32<uint32_t>( long_state + j );
			const uint32_t x_1 = __shfl( x_0, sub + 1, 4 );
			const uint32_t x_2 = __shfl( x_0, sub + 2, 4 );
			const uint32_t x_3 = __shfl( x_0, sub + 3, 4 );
			d[x] = a ^
				t_fn0( x_0 & 0xff ) ^
				t_fn1( (x_1 >> 8) & 0xff ) ^
				t_fn2( (x_2 >> 16) & 0xff ) ^
				t_fn3( ( x_3 >> 24 ) );


			//XOR_BLOCKS_DST(c, b, &long_state[j]);
			t1[0] = __shfl( (int) d[x], 0, 4 );
			//long_state[j] = d[0] ^ d[1];
			storeGlobal32( long_state + j, d[0] ^ d[1] );

			//MUL_SUM_XOR_DST(c, a, &long_state[((uint32_t *)c)[0] & 0x1FFFF0]);
			j = ( ( *t1 & 0x1FFFF0 ) >> 2 ) + sub;

			uint32_t yy[2];
			*( (uint64_t*) yy ) = loadGlobal64<uint64_t>( ( (uint64_t *) long_state )+( j >> 1 ) );
			uint32_t zz[2];
			zz[0] = __shfl( yy[0], 0, 4 );
			zz[1] = __shfl( yy[1], 0, 4 );

			t1[1] = __shfl( (int) d[x], 1, 4 );
			#pragma unroll
			for ( k = 0; k < 2; k++ )
				t2[k] = __shfl( (int) a, k + sub2, 4 );
			asm(
				"mad.lo.u64 %0, %2, %3, %4;\n\t"
				"mad.hi.u64 %1, %2, %3, %4;\n\t"
				 : "=l"( reslo ), "=l"( reshi )
				: "l"( *( (uint64_t *) t1 ) ), "l"( *( (uint64_t*) zz ) ), "l"( *( (uint64_t *) t2 ) ) );
			res = ( sub2 ? reslo : reshi ) >> ( sub & 1 ? 32 : 0 );

			storeGlobal32( long_state + j, res );
			a = ( sub & 1 ? yy[1] : yy[0] ) ^ res;
		}
	}

	if ( bfactor > 0 )
	{
		ctx_a[sub] = a;
		ctx_b[sub] = d[1];
	}

#else // __CUDA_ARCH__ < 300

	const int thread = blockDim.x * blockIdx.x + threadIdx.x;

	if ( thread >= threads )
		return;

	int i, j;
	const int batchsize = ITER >> ( 2 + bfactor );
	const int start = partidx * batchsize;
	const int end = start + batchsize;
	uint32_t * __restrict__ long_state = &d_long_state[(IndexType) thread << 19];
	uint32_t * __restrict__ ctx_a = d_ctx_a + thread * 4;
	uint32_t * __restrict__ ctx_b = d_ctx_b + thread * 4;
	uint32_t a[4], b[4], c[4];

	MEMCPY8( a, ctx_a, 2 );
	MEMCPY8( b, ctx_b, 2 );

	for ( i = start; i < end; ++i )
	{
		j = ( a[0] & 0x1FFFF0 ) >> 2;
		cn_aes_single_round( sharedMemory, &long_state[j], c, a );
		XOR_BLOCKS_DST( c, b, &long_state[j] );
		MUL_SUM_XOR_DST( c, a, &long_state[( c[0] & 0x1FFFF0 ) >> 2] );
		j = ( a[0] & 0x1FFFF0 ) >> 2;
		cn_aes_single_round( sharedMemory, &long_state[j], b, a );
		XOR_BLOCKS_DST( b, c, &long_state[j] );
		MUL_SUM_XOR_DST( b, a, &long_state[( b[0] & 0x1FFFF0 ) >> 2] );
	}

	if ( bfactor > 0 )
	{
		MEMCPY8( ctx_a, a, 2 );
		MEMCPY8( ctx_b, b, 2 );
	}

#endif // __CUDA_ARCH__ >= 300
}

__global__ void cryptonight_core_gpu_phase3( int threads, int bfactor, int partidx, const uint32_t * __restrict__ long_state, uint32_t * __restrict__ d_ctx_state, uint32_t * __restrict__ d_ctx_key2 )
{
	__shared__ uint32_t sharedMemory[1024];

	cn_aes_gpu_init( sharedMemory );
	__syncthreads( );

	int thread = ( blockDim.x * blockIdx.x + threadIdx.x ) >> 3;
	int sub = ( threadIdx.x & 7 ) << 2;

	const int batchsize = 0x80000 >> bfactor;
	const int start = partidx * batchsize;
	const int end = start + batchsize;

	if ( thread >= threads )
		return;

	uint32_t key[40], text[4];
	MEMCPY8( key, d_ctx_key2 + thread * 40, 20 );
	MEMCPY8( text, d_ctx_state + thread * 50 + sub + 16, 2 );

	__syncthreads( );
	for ( int i = start; i < end; i += 32 )
	{
#pragma unroll
		for ( int j = 0; j < 4; ++j )
			text[j] ^= long_state[((IndexType) thread << 19) + (sub + i + j)];

		cn_aes_pseudo_round_mut( sharedMemory, text, key );
	}

	MEMCPY8( d_ctx_state + thread * 50 + sub + 16, text, 2 );
}

extern "C" void cryptonight_core_cpu_hash(nvid_ctx* ctx)
{
	dim3 grid( ctx->device_blocks );
	dim3 block( ctx->device_threads );
	dim3 block4( ctx->device_threads << 2 );
	dim3 block8( ctx->device_threads << 3 );

	int partcount = 1 << ctx->device_bfactor;

	/* bfactor for phase 1 and 3
	 *
	 * phase 1 and 3 consume less time than phase 2, therefore we begin with the
	 * kernel splitting if the user defined a `bfactor >= 5`
	 */
	int bfactorOneThree = ctx->device_bfactor - 4;
	if( bfactorOneThree < 0 )
		bfactorOneThree = 0;

	int partcountOneThree = 1 << bfactorOneThree;

	for ( int i = 0; i < partcountOneThree; i++ )
	{
		cryptonight_core_gpu_phase1<<< grid, block8 >>>( ctx->device_blocks*ctx->device_threads,
			bfactorOneThree, i,
			ctx->d_long_state, ctx->d_ctx_state, ctx->d_ctx_key1 );
		exit_if_cudaerror( ctx->device_id, __FILE__, __LINE__ );

		if ( partcount > 1 && ctx->device_bsleep > 0) compat_usleep( ctx->device_bsleep );
	}
	if ( partcount > 1 && ctx->device_bsleep > 0) compat_usleep( ctx->device_bsleep );

	for ( int i = 0; i < partcount; i++ )
	{
		cryptonight_core_gpu_phase2<<< grid, ( ctx->device_arch[0] >= 3 ? block4 : block ) >>>( ctx->device_blocks*ctx->device_threads,
			ctx->device_bfactor, i, ctx->d_long_state, ctx->d_ctx_a, ctx->d_ctx_b );
		exit_if_cudaerror( ctx->device_id, __FILE__, __LINE__ );

		if ( partcount > 1 && ctx->device_bsleep > 0) compat_usleep( ctx->device_bsleep );
	}

	for ( int i = 0; i < partcountOneThree; i++ )
	{
		cryptonight_core_gpu_phase3<<< grid, block8 >>>( ctx->device_blocks*ctx->device_threads,
			bfactorOneThree, i,
			ctx->d_long_state,
			ctx->d_ctx_state, ctx->d_ctx_key2 );
		exit_if_cudaerror( ctx->device_id, __FILE__, __LINE__ );
	}
}
