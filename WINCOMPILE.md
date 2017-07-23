# Compile **xmr-stak** for Windows

**warning** CUDA 8 is not supporting VS2017 therefore do not miss the CMake option `-T v140,host=x64`

## Install Dependencies

### Preparation

- open a command line `cmd`
- run `mkdir C:\xmr-stak-dep`

### Visual Studio 2017 Community

- download VS2017 Community and install from [https://www.visualstudio.com/downloads/](https://www.visualstudio.com/downloads/)
- during the install chose the components
  - `Desktop development with C++` (left side)
  - `Toolset for Visual Studio C++ 2015.3 v140...` (right side)

### Cuda 8.0+

- donwload and install [https://developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads)
- for minimal install choose `Custom installation options` during the install and select
    - CUDA/Develpment
    - CUDA/Visual Studio Integration (ignore the warning during the install that VS2017 is not supported)
    - CUDA/Runtime
    - Driver components

### CMake for Win64

- download and install the latest version from [https://cmake.org/download/](https://cmake.org/download/)
- tested version: [cmake 3.9](https://cmake.org/files/v3.9/cmake-3.9.0-rc3-win64-x64.msi)
- during the install choose the option `Add CMake to the system PATH for all users`

### OpenSSL for Win64

- download and install the precompiled binary form [https://slproweb.com/products/Win32OpenSSL.html](https://slproweb.com/products/Win32OpenSSL.html)
- tested version: [OpenSSL 1.0.2L](https://slproweb.com/download/Win64OpenSSL-1_0_2L.exe)

### Microhttpd for Win32

- download the precompiled binary from [http://ftpmirror.gnu.org/libmicrohttpd/](http://ftpmirror.gnu.org/libmicrohttpd/)
- tested version: [libmicrohttpd-0.9.55-w32-bin](http://mirror.reismil.ch/gnu/libmicrohttpd/libmicrohttpd-0.9.55-w32-bin.zip)
- unzip microhttpd to `C:\xmr-stak-dep`
- Add the microhttpd lib folder to the enviroment variable `MICROHTTPD_ROOT` (if you follow exactly the steps before: `C:\xmr-stak-dep\libmicrohttpd-0.9.55-w32-bin\x86_64\VS2017\Release-static`)

### Validate the Dependency Folder

- open a command line `cmd`
- run
   ```
   cd c:\xmr-stak-dep
   tree .
   ```
- the result should have the same structure
  ```
    C:\XMR-STAK-DEP
    └───libmicrohttpd-0.9.55-w32-bin
        ├───x86
        │   ├───MinGW
        │   │   ├───shared
        │   │   │   └───mingw32
        │   │   │       ├───bin
        │   │   │       ├───include
        │   │   │       └───lib
        │   │   │           └───pkgconfig
        │   │   ├───shared-xp
        │   │   │   └───mingw32
        │   │   │       ├───bin
        │   │   │       ├───include
        │   │   │       └───lib
        │   │   │           └───pkgconfig
        │   │   ├───static
        │   │   │   └───mingw32
        │   │   │       ├───include
        │   │   │       └───lib
        │   │   │           └───pkgconfig
        │   │   └───static-xp
        │   │       └───mingw32
        │   │           ├───include
        │   │           └───lib
        │   │               └───pkgconfig
        │   ├───VS2013
        │   │   ├───Release-dll
        │   │   ├───Release-dll-xp
        │   │   ├───Release-static
        │   │   └───Release-static-xp
        │   ├───VS2015
        │   │   ├───Debug-dll
        │   │   ├───Debug-dll-xp
        │   │   ├───Debug-static
        │   │   ├───Debug-static-xp
        │   │   ├───Release-dll
        │   │   ├───Release-dll-xp
        │   │   ├───Release-static
        │   │   └───Release-static-xp
        │   └───VS2017
        │       ├───Debug-dll
        │       ├───Debug-static
        │       ├───Release-dll
        │       └───Release-static
        └───x86_64
            ├───MinGW
            │   ├───shared
            │   │   └───mingw64
            │   │       ├───bin
            │   │       ├───include
            │   │       └───lib
            │   │           └───pkgconfig
            │   └───static
            │       └───mingw64
            │           ├───include
            │           └───lib
            │               └───pkgconfig
            ├───VS2013
            │   ├───Release-dll
            │   └───Release-static
            ├───VS2015
            │   ├───Debug-dll
            │   ├───Debug-static
            │   ├───Release-dll
            │   └───Release-static
            └───VS2017
                ├───Debug-dll
                ├───Debug-static
                ├───Release-dll
                └───Release-static
  ```

## Compile

- download and unzip `xmr-stak-nvidia`
- open a command line `cmd`
- `cd` to your unzipped source code directory
- execute the following commands (NOTE: path to VS2017 can be different)
  ```
  "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsMSBuildCmd.bat"
  set CMAKE_PREFIX_PATH=C:\xmr-stak-dep\libmicrohttpd-0.9.55-w32-bin\x86_64\VS2017\Release-static
  mkdir build
  cd build
  cmake -G "Visual Studio 15 2017 Win64" -T v140,host=x64 ..
  msbuild xmr-stak-nvidia.sln /p:Configuration=Release
  cd bin\Release
  copy ..\..\..\config.txt .
  ```
- customize your `config.txt` file by adding the pool, username and password

If your system does not recognize msbuild as a command, you can also open the solution with Visual Studio 2017, select the right configuration (Release, x64) and build within the IDE (Pressing F7)
