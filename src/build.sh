#!/usr/bin/bash

HCE_DRP_BUILD() {

  verify_prerequisites() {
    if ! [ -d "$VCPKG_ROOT" ]; then
      echo "Environment variable VCPKG_ROOT is unset! See https://learn.microsoft.com/en-us/vcpkg/users/config-environment#vcpkg_root"
      echo 1
      return 1
    fi
    if ! echo "$PATH" | grep "$VCPKG_ROOT"; then
      # echo "VCPKG_ROOT must be in PATH!"
      # return 1
      export PATH=$PATH:$VCPKG_ROOT
    fi
  }
  if ! verify_prerequisites; then
    return $?
  fi

  getCmakeHost() {
    # https://www.wikipedia.org/wiki/Uname#Examples
    # https://cmake.org/cmake/help/latest/variable/CMAKE_HOST_SYSTEM_NAME.html
    # file://./CMakePresets.json
    case "$(uname)" in

    Linux)
      echo linux
      return 0
      ;;

    CYGWIN_NT-5.1 | CYGWIN_NT-6.1 | CYGWIN_NT-6.1-WOW64 | CYGWIN_NT-10.0 | MINGW32_NT-6.1 | MINGW64_NT-6.1 | "Windows NT" | Windows_NT | WindowsNT | Windows)
      echo windows
      return 0
      ;;

    Darwin)
      echo macos
      return 0
      ;;

    *)
      >&2 echo "Your host platform is not supported"
      return 1
      ;;

    esac
  }

  if which dotnet >/dev/null; then
    cleanFirst=false
    for arg in "$@"; do
      if [[ $arg == *"--clean"* ]]; then
        cleanFirst=true
        break
      fi
    done
    $cleanFirst && dotnet clean ./DRP.nativeproj
    dotnet build ./DRP.nativeproj --verbosity diagnostic --configuration release
    return $?
  else
    WARN_MESSAGE_DOTNET_MISSING="WARNING: cannot find executable \"dotnet\"!\nAttempting to directly invoke CMake..."
    echo -e "\e[33m$WARN_MESSAGE_DOTNET_MISSING\e[0m"
  fi

  if ! [ -f CMakeLists.txt ]; then
    echo 'src/build.sh is running in the wrong directory!'
    return 1
  fi

  clean=""
  if echo "$@" | grep '--clean'; then
    clean="--clean-first"
  fi

  presetName=$(getCmakeHost)

  export VCPKG_USE_NUGET_CACHE=1
  cmake $clean --preset "$presetName-base" &&
    cmake --build --preset "$presetName" --config Release
}

HCE_DRP_BUILD "$@"
