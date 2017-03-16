### XMR-Stak-NVIDIA - Monero mining software

XMR-Stak is a universal Stratum pool miner. This is the NVIDIA GPU mining version; there is also an [AMD GPU version](https://github.com/fireice-uk/xmr-stak-amd), and a [CPU version](https://github.com/fireice-uk/xmr-stak-cpu).

#### HTML reports

<img src="https://gist.githubusercontent.com/fireice-uk/2da301131ac01695ff79539a27b81d68/raw/e948641897ba79e5a6ee78e8248cc07779d6eac7/xmr-stak-nvidia-hashrate.png" width="260"> <img src="https://gist.githubusercontent.com/fireice-uk/2da301131ac01695ff79539a27b81d68/raw/e948641897ba79e5a6ee78e8248cc07779d6eac7/xmr-stak-nvidia-results.png" width="260"> <img src="https://gist.githubusercontent.com/fireice-uk/2da301131ac01695ff79539a27b81d68/raw/e948641897ba79e5a6ee78e8248cc07779d6eac7/xmr-stak-nvidia-connection.png" width="260">

The hashrate shown above was generated on an overclocked GTX 1070.

#### Usage on Windows 
1) Edit the config.txt file to enter your pool login and password. 
2) Double click the exe file. 

XMR-Stak should compile on any C++11 compliant compiler. Windows compiler is assumed to be MSVC 2015 CE. MSVC build environment is not vendored.

```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Windows binary release checksums

sha1sum
eef10937dc705a54b85b19f6f91e45d3748e7af3  xmr-stak-nvidia.exe
71b92b64727042607ed80c0f32dff4e7b9306381  xmr-stak-nvidia-notls.exe
a4c5aefbf0af000dca264c3342a68fa41fb6e272  cudart64_80.dll
d34a0ba0dd7b3b1f900a7e02772e197e974b4a73  libeay32.dll
2ee9966a0fc163da58408d91be36b84fa287c10b  ssleay32.dll

sha3sum
56849450e3b1fd510b7e1968812aafb12ed8f67dbe65bc0a72c8d62f  xmr-stak-nvidia.exe
7e26dc72197b8eb746dc826cb23358abe593dc80157caff00d094c73  xmr-stak-nvidia-notls.exe
571633217a1592d56239d0a55c046b0e3e38cd68548b141b830a44c6  cudart64_80.dll
133c065d9ef2c93396382e2ba5d8c3ca8c6a57c6beb0159cb9a4b6c5  ssleay32.dll
05003137a87313c81d6c348c9b96411c95d48dc22c35f36c39129747  libeay32.dll

date
Thu 16 Mar 00:29:17 GMT 2017
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJYydx6AAoJEPsk95p+1Bw0lGoH/i2/MqaKW79xwIJLRs3HsHqs
gAKHLkK2irzN2wFIW6spMZPky046lsp2yZrEakOgUWHamjHg618y5dd9SZ3rvJQa
fB03wmbArlMRjcaU7KZkazFz30+ne7QCf5jtSYiAOLbSHuMJFaEKMJl5qURasxDZ
/6kAxugAmRG9VKQxmwfei2cKSIfwgqXBIF2FK52ZRtAc5mr4mpttfegRFdfFpAP1
UxBr4dueqRwja5v4ABZJtXJu1GfOCoNEeXalnkTFuf4a1bRyg7R1wcJmgFS9pvf5
bKXMIwVJkuFZ/rrJkNuYHVO0Ykn1QwjrWHefKDe+Z7y+Ub0DASjyzhG5ARdDb5c=
=Y+FT
-----END PGP SIGNATURE-----

```

#### Usage on Linux (Debian-based distros)
```
    sudo apt-get install nvidia-cuda-dev nvidia-cuda-toolkit libmicrohttpd-dev libssl-dev cmake build-essential
    cmake .
    make
```

GCC version 5.1 or higher is required for full C++11 support. CMake release compile scripts, as well as CodeBlocks build environment for debug builds is included.

#### GCC 6
Unfortunately CUDA 8.0 does not support GCC 6 without nasty hacks. However clang 3.8+ is supported. If you have CUDA 8.0, and GCC 6 I would advise to build the miner using clang instead.

```
    sudo apt-get install clang
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
    cmake .
    make
```

#### Default dev donation
By default the miner will donate 1% of the hashpower (1 minute in 100 minutes) to my pool. If you want to change that, edit **donate-level.h** before you build the binaries.

If you want to donate directly to support further development, here is my wallet

```
4581HhZkQHgZrZjKeCfCJxZff9E3xCgHGF25zABZz7oR71TnbbgiS7sK9jveE6Dx6uMs2LwszDuvQJgRZQotdpHt1fTdDhk
```

#### PGP Key
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

### Common Issues

**msvcp140.dll and vcruntime140.dll not available errors**

Download and install this [runtime package](https://www.microsoft.com/en-us/download/details.aspx?id=48145) from Microsoft.  *Warning: Do NOT use "missing dll" sites - dll's are exe files with another name, and it is a fairly safe bet that any dll on a shady site like that will be trojaned.  Please download offical runtimes from Microsoft above.*



