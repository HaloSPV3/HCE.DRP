# Copyright 2026 Noah Sherwin
# SPDX-License-Identifier: GPL-3.0-only

# Configure the search behavior for external dependencies
# MUST be set before vcpkg is loaded!
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# CMake determines how to examine dependencies based on the *host* system, leading to
# a `file unknown error` unless the target platform is explicitly specified.
set(CMAKE_GET_RUNTIME_DEPENDENCIES_PLATFORM "windows+pe")

# ##############
# ## vcpkg
# ##############
if(NOT VCPKG_ROOT)
  set(VCPKG_ROOT $ENV{VCPKG_ROOT})
endif()

if(NOT IS_DIRECTORY ${VCPKG_ROOT})
  message(FATAL_ERROR "VCPKG_ROOT cannot be found!")
endif()

set(USE_MSVC_WINE ${USE_MSVC_WINE})

if(NOT USE_MSVC_WINE AND NOT "$ENV{USE_MSVC_WINE}" STREQUAL "")
  set(USE_MSVC_WINE "$ENV{USE_MSVC_WINE}")
endif()

if(CMAKE_HOST_WIN32 OR USE_MSVC_WINE)
  if(USE_MSVC_WINE)
    include(${CMAKE_SOURCE_DIR}/cmake/msvc-wine.cmake)
  endif()

  # set(VCPKG_CMAKE_SYSTEM_NAME Windows)
  set(VCPKG_TARGET_TRIPLET x86-windows-static-md)
  set(VCPKG_PLATFORM_TOOLSET v141)

  # https://learn.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=msvc-170
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MD")

else()
  # https://github.com/microsoft/vcpkg/blob/master/triplets/community/x86-mingw-static-release.cmake
  # vcpkg/triplets/community/x86-mingw-static-release.cmake
  set(VCPKG_TARGET_TRIPLET x86-mingw-static-release) # '-dynamic' would make a separate "libdiscord-rpc.dll"

  # CMAKE_C_COMPILER, CMAKE_CXX_COMPILER, and CMAKE_RC_COMPILER are set by the triplet
  # CMAKE_C_FLAGS_INIT, CMAKE_CXX_FLAGS_INIT, and CMAKE_EXE_LINKER_FLAGS_INIT are set in ./toolchain_loader.cmake
endif()

set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_MANIFEST_MODE true)

string(TOLOWER "${CMAKE_TOOLCHAIN_FILE}" cmake_toolchain_file)
string(REGEX MATCH "[\\/]vcpkg.cmake" IsVcpkgCMake "${cmake_toolchain_file}")

# if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)

# if CMAKE_TOOLCHAIN_FILE is defined and not vcpkg, retain it as
# CMAKE_TOOLCHAIN_FILE_0. Then, assign vcpkg as the main toolchain.
if(NOT IsVcpkgCMake)
  if(NOT "${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
    chain(${CMAKE_TOOLCHAIN_FILE})
  endif()

  set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
endif()

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/toolchain_loader.cmake")
