# XMR-Stak-NVIDIA - Monero mining software

XMR-Stak is a universal Stratum pool miner. This is the NVIDIA GPU mining version; there is also an [AMD GPU version](https://github.com/fireice-uk/xmr-stak-amd), and a [CPU version](https://github.com/fireice-uk/xmr-stak-cpu).

## HTML reports

<img src="https://gist.githubusercontent.com/fireice-uk/2da301131ac01695ff79539a27b81d68/raw/e948641897ba79e5a6ee78e8248cc07779d6eac7/xmr-stak-nvidia-hashrate.png" width="260"> <img src="https://gist.githubusercontent.com/fireice-uk/2da301131ac01695ff79539a27b81d68/raw/e948641897ba79e5a6ee78e8248cc07779d6eac7/xmr-stak-nvidia-results.png" width="260"> <img src="https://gist.githubusercontent.com/fireice-uk/2da301131ac01695ff79539a27b81d68/raw/e948641897ba79e5a6ee78e8248cc07779d6eac7/xmr-stak-nvidia-connection.png" width="260">

The hashrate shown above was generated on an overclocked GTX 1070.

## Usage on Windows 
1) Edit the config.txt file to enter your pool login and password. 
2) Double click the exe file. 

XMR-Stak should compile on any C++11 compliant compiler. Windows compiler is assumed to be MSVC 2015 CE. MSVC build environment is not vendored.

```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Windows binary release checksums

sha1sum
db795d6ac4f5debf0a476f8f4e26baa5ecaf49aa  xmr-stak-nvidia.exe
a5e957bfbf0ec172f0795e07384829a1b6a29910  xmr-stak-nvidia-notls.exe
a4c5aefbf0af000dca264c3342a68fa41fb6e272  cudart64_80.dll
d34a0ba0dd7b3b1f900a7e02772e197e974b4a73  libeay32.dll
2ee9966a0fc163da58408d91be36b84fa287c10b  ssleay32.dll

sha3sum
d3740b4046ec596cb2d9cfbc9a0e32bd5ae51fe786ba4c205f5f0166  xmr-stak-nvidia.exe
d7860e4465e1c88a5a133248afd651c2d4ef27b1eda85ceb9c8f07c5  xmr-stak-nvidia-notls.exe
571633217a1592d56239d0a55c046b0e3e38cd68548b141b830a44c6  cudart64_80.dll
133c065d9ef2c93396382e2ba5d8c3ca8c6a57c6beb0159cb9a4b6c5  ssleay32.dll
05003137a87313c81d6c348c9b96411c95d48dc22c35f36c39129747  libeay32.dll

date
Sun 23 Apr 23:23:01 BST 2017

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJY/SlhAAoJEPsk95p+1Bw0f0MH/0/6g6A+PtIbVrW5rcdroVBQ
o8/+KWJXmxDgTCzmPcZTq0rw7mIyfMDTYYtDX6VACtMdbpZkWmVlcRwSS2BrfEoq
2DS7MgNhbAc4J8ykmuVO+lkNmanbkNsqCwLjF37KAvpeaJOV2dAIjqXAeMshZdq0
fqlKZq7FHcaRmwLC4BWvXczjYmwL1B8s9sdPyulMHom6knXMavN8zrJ7FkBJnqdc
7A/f5AAPYzryDDfk5Vicdo8vt/ZAcy7jKUSjQew5wED6vabUqZsYgNwIQlQVj82e
wwNwFCe2W4VNKJfTmSZ7uxzNNHI9hml7W58wT8zFLG/OYjaYLuTnRDI0shePJA8=
=7wrx
-----END PGP SIGNATURE-----

```

## Compile on Linux (Debian-based distros)

### GNU Compiler
```
    sudo apt-get install nvidia-cuda-dev nvidia-cuda-toolkit libmicrohttpd-dev libssl-dev cmake cmake-curses-gui build-essential
    cmake .
    make install
```

- GCC version 5.1 or higher is required for full C++11 support. CMake release compile scripts, as well as CodeBlocks build environment for debug builds is included.
- Unfortunately CUDA 8.0 does not support **GCC 6** without nasty hacks. However clang 3.8+ is supported. If you have CUDA 8.0, and GCC 6 I would advise to build the miner using clang instead.

### Clang Compile
```
    sudo apt-get install clang
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
    cmake .
    make install
```
You can find a complete compile guide under [Advanced Compile Options](#advanced-compile-options).

## Default dev donation

By default the miner will donate 1% of the hashpower (1 minute in 100 minutes) to our pool. If you want to change that, edit **donate-level.h** before you build the binaries.

If you want to donate directly to support further development, here are our wallets

fireice-uk:
```
4581HhZkQHgZrZjKeCfCJxZff9E3xCgHGF25zABZz7oR71TnbbgiS7sK9jveE6Dx6uMs2LwszDuvQJgRZQotdpHt1fTdDhk
```

psychocrypt:
```
43NoJVEXo21hGZ6tDG6Z3g4qimiGdJPE6GRxAmiWwm26gwr62Lqo7zRiCJFSBmbkwTGNuuES9ES5TgaVHceuYc4Y75txCTU
```

## Common Issues

**msvcp140.dll and vcruntime140.dll not available errors**

Download and install this [runtime package](https://www.microsoft.com/en-us/download/details.aspx?id=48145) from Microsoft.  *Warning: Do NOT use "missing dll" sites - dll's are exe files with another name, and it is a fairly safe bet that any dll on a shady site like that will be trojaned.  Please download offical runtimes from Microsoft above.*


## Advanced Compile Options

The build system is CMake, if you are not familiar with CMake you can learn more [here](https://cmake.org/runningcmake/).

### Short Description

There are two easy ways to set variables for `cmake` to configure *xmr-stak-nvidia*
- use the ncurses GUI
  - `ccmake .`
  - edit your options
  - end the GUI by pressing the key `c`(create) and than `g`(generate)
- set Options on the command line
  - enable a option: `cmake . -DNAME_OF_THE_OPTION=ON`
  - disable a option `cmake . -DNAME_OF_THE_OPTION=OFF`
  - set a value `cmake . -DNAME_OF_THE_OPTION=value`

After the configuration you need to call
`make install` for slow sequential build
or
`make -j install` for faster parallel build
and install.

### xmr-stak-nvidia Compile Options
- `CMAKE_INSTALL_PREFIX` install miner to the home folder
  - `cmake . -DCMAKE_INSTALL_PREFIX=$HOME/xmr-stak-nvidia`
  - you can find the binary and the `config.txt` file after `make install` in `$HOME/xmr-stak-nvidia/bin`
-`CMAKE_BUILD_TYPE` set the build type
  - valid options: `Release` or `Debug`
  - you should always keep `Release` for your productive miners
- `CUDA_ARCH` build for a certain compute architecture
  - this option needs a semicolon separated list
  - `cmake . -DCUDA_ARCH=61` or `cmake . -DCUDA_ARCH=20;61`
  - [list](https://developer.nvidia.com/cuda-gpus) with NVIDIA compute architectures
  - by default the miner is created for all currently available compute architectures
- `CUDA_COMPILER` select the compiler for the device code
  - valid options: `nvcc` or `clang` if clang 3.9+ is installed
```
    # compile host and device code with clang
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
    cmake . -DCUDA_COMPILER=clang
```
- `MICROHTTPD_REQUIRED` allow to disable/enable the dependency *microhttpd*
  - by default enabled
  - there is no *http* interface available if option is disabled: `cmake . -DMICROHTTPD_REQUIRED=OFF`
- `OpenSSL_REQUIRED`allow to disable/enable the dependency *OpenSSL*
  - by default enabled
  - it is not possible to connect to a *TLS* secured pool if optin is disabled: `cmake . -DOpenSSL_REQUIRED=OFF`
- `XMR-STAK_LARGEGRID` use `32` or `64` bit integer for on device indices
  - default is enabled
  - on old GPUs it can increase the hash rate if disabled: `cmake . -DXMR-STAK_LARGEGRID=OFF`
  - if disabled it is not allowed to use more than `1000` threads on the device
- `XMR-STAK_THREADS` give the compiler information which value for `threads` is used at runtime
  - default is `0` (compile time optimization)
  - if the miner is compiled and used at runtime with the some value it can increase the hash rate: `cmake . -DXMR-STAK_THREADS=32`

## Tune Performance `config.txt`

### Choose Value for `threads` and `blocks`

The optimal parameter for the `threads` and `blocks` option in `config.txt` depend on your GPU.
For all GPU's with a compute capability `>=2.0` and `<6.0` there is a restriction of the amount of RAM that can be used for the mining algorithm.
The maximum RAM that can be used must be less than 2GB (e.g. GTX TITAN) or 1GB (e.g. GTX 750-TI).
The amount of RAM used for mining can be changed with `"threads" : T, "blocks : B"`.
  - `T` = threads used per block
  - `B` = CUDA blocks started (should be a multiple of the multiprocessors `M` on the GPU)

For the 2GB limit the equations must be full filled: `T * B * 2 <= 1900` and ` B mod M == 0`.
The value `1900` is used because there is a little data overhead for administration.
The GTX Titan X has 24 multiprocessors `M`, this means a valid and good starting configuration is `"threads" : 16, "blocks : 48"`
and full fill all restrictions `16 * 48 * 2 = 1536` and `48 mod 24 = 0`.

The memory limit for NVIDIA Pascal GPUs is `16` GiB if the newest CUDA driver is used.

### Windows or Linux Interactive Usage

To work (surf) with you desktop system while you are running the miner you need to find a good value for `bfactor` and `bsleep`.
On windows, you need to set the option `bfactor` and `bsleep` if the miner crashs shortly after starting.
A good value to start on windows is `"bfactor" : 6, "bsleep" :  25`.
To reach the maximum hash rate you must set both values to zero `"bfactor" : 0, "bsleep" : 0`.

## PGP Key
```
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

mQENBFhYUmUBCAC6493W5y1MMs38ApRbI11jWUqNdFm686XLkZWGDfYImzL6pEYk
RdWkyt9ziCyA6NUeWFQYniv/z10RxYKq8ulVVJaKb9qPGMU0ESfdxlFNJkU/pf28
sEVBagGvGw8uFxjQONnBJ7y7iNRWMN7qSRS636wN5ryTHNsmqI4ClXPHkXkDCDUX
QvhXZpG9RRM6jsE3jBGz/LJi3FyZLo/vB60OZBODJ2IA0wSR41RRiOq01OqDueva
9jPoAokNglJfn/CniQ+lqUEXj1vjAZ1D5Mn9fISzA/UPen5Z7Sipaa9aAtsDBOfP
K9iPKOsWa2uTafoyXgiwEVXCCeMMUjCGaoFBABEBAAG0ImZpcmVpY2VfdWsgPGZp
cmVpY2UueG1yQGdtYWlsLmNvbT6JATcEEwEIACEFAlhYUmUCGwMFCwkIBwIGFQgJ
CgsCBBYCAwECHgECF4AACgkQ+yT3mn7UHDTEcQf8CMhqaZ0IOBxeBnsq5HZr2X6z
E5bODp5cPs6ha1tjH3CWpk1AFeykNtXH7kPW9hcDt/e4UQtcHs+lu6YU59X7xLJQ
udOkpWdmooJMXRWS/zeeon4ivT9d69jNnwubh8EJOyw8xm/se6n48BcewfHekW/6
mVrbhLbF1dnuUGXzRN1WxsUZx3uJd2UvrkJhAtHtX92/qIVhT0+3PXV0bmpHURlK
YKhhm8dPLV9jPX8QVRHQXCOHSMqy/KoWEe6CnT0Isbkq3JtS3K4VBVeTX9gkySRc
IFxrNJdXsI9BxKv4O8yajP8DohpoGLMDKZKSO0yq0BRMgMh0cw6Lk22uyulGALkB
DQRYWFJlAQgAqikfViOmIccCZKVMZfNHjnigKtQqNrbJpYZCOImql4FqbZu9F7TD
9HIXA43SPcwziWlyazSy8Pa9nCpc6PuPPO1wxAaNIc5nt+w/x2EGGTIFGjRoubmP
3i5jZzOFYsvR2W3PgVa3/ujeYYJYo1oeVeuGmmJRejs0rp1mbvBSKw1Cq6C4cI0x
GTY1yXFGLIgdfYNMmiLsTy1Qwq8YStbFKeUYAMMG3128SAIaT3Eet911f5Jx4tC8
6kWUr6PX1rQ0LQJqyIsLq9U53XybUksRfJC9IEfgvgBxRBHSD8WfqEhHjhW1VsZG
dcYgr7A1PIneWsCEY+5VUnqTlt2HPaKweQARAQABiQEfBBgBCAAJBQJYWFJlAhsM
AAoJEPsk95p+1Bw0Pr8H/0vZ6U2zaih03jOHOvsrYxRfDXSmgudOp1VS45aHIREd
2nrJ+drleeFVyb14UQqO/6iX9GuDX2yBEHdCg2aljeP98AaMU//RiEtebE6CUWsL
HPVXHIkxwBCBe0YkJINHUQqLz/5f6qLsNUp1uTH2++zhdBWvg+gErTYbx8aFMFYH
0GoOtqE5rtlAh5MTvDZm+UcDwKJCxhrLaN3R3dDoyrDNRTgHQQuX5/opJBiUnVNK
d+vugnxzpMIJQP11yCZkz/KxV8zQ2QPMuZdAoh3znd/vGCJcp0rWphn4pqxA4vDp
c4hC0Yg9Dha1OoE5CJCqVL+ic4vAyB1urAwBlsd/wH8=
=B5I+
-----END PGP PUBLIC KEY BLOCK-----
```
