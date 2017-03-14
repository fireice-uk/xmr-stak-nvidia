#ifndef __CRYPTONIGHT_H_INCLUDED
#define __CRYPTONIGHT_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <inttypes.h>

#define MEMORY  2097152

typedef struct {
	uint8_t hash_state[224]; // Need only 200, explicit align
	uint8_t long_state[MEMORY];
} cryptonight_ctx;

void cryptonight_hash_ctx(const void* input, size_t len, void* output, cryptonight_ctx* ctx);
void cryptonight_hash_ctx_soft(const void* input, size_t len, void* output, cryptonight_ctx* ctx);

#ifdef __cplusplus
}
#endif

#endif
