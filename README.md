# DISCORD RICH PRESENCE

This tree contains the DRP (Discord Rich Presence) source code, which
aims to integrate Halo CE and SPV3 with Discord by allowing players to display the
mission & difficulty they're playing on.

The source code has been generously developed and provided by giraffe,
and has been integrated into a CMake project for convenient
reproducible builds.

## COMPILING

Run `cd src && bash ./build.sh` or run `dotnet build` directly. The .NET SDK's build system
invokes CMake. CMake is used to generate a Ninja project that compiled with MSVC
on Windows or MinGW on other host platforms.

### Build Configurations

#### Build Mode(s)

- Debug
- Release (effectively MinSizeRel)

#### CPU/OS Architecture(s)

- x86 (i386/i686)

The output binary is intended for the Windows 32-bit ports of Halo: CE. As of
September 2026, there is no reason to build AMD64/x86_64 nor ARM64 binaries.

#### misc

The DLL is compiled to the following paths in the following contexts:

|               | debug                                                             | release
| ------------- | ----------------------------------------------------------------- | -------
| **x86**       | artifacts/bin/DRP/debug_win-x86/win-x86/native/halocepresence.dll | artifacts/bin/DRP/release_win-x86/win-x86/native/halocepresence.dll
| **x64** (N/A) | artifacts/bin/DRP/debug_win-x64/win-x64/native/halocepresence.dll | artifacts/bin/DRP/release_win-x64/win-x64/native/halocepresence.dll

- `dotnet build` will invoke a CMake build with tools appropriate for your system i.e. MinGW on Linux and MacOS; MSVC on Windows.
  - `dotnet build -v diag` will print errors if you encounter any.
- `dotnet publish` will invoke a CMake Release/MinSizeRel build and ZIP the runtime DLL to `.git/config/../../publish/halocepresence*.zip`.
  - standalone clone: `./publish/*.zip`
  - git-submodule at `SPV3.Loader/ext/HCE.DRP`: `SPV3.Loader/publish/halocepresence*.zip`

## RESOURCES

The drp/resources directory stores the images used in the Discord Rich
Presence:

| directory  | description
| ---------- | --------------------------------------------
| maps       | images representing each map
| difficulty | images representing each singleplayer difficulty

Images have been generously provided by Arecaidian Fox, giraffe, sbdJazz
and the rest of the SPV3 crew.
