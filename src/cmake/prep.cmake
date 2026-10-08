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
  set(CACHE{VCPKG_ROOT} TYPE FILEPATH VALUE "$ENV{VCPKG_ROOT}")
endif()

if(NOT IS_DIRECTORY ${VCPKG_ROOT})
  message(FATAL_ERROR "VCPKG_ROOT cannot be found!")
endif()

set(USE_MSVC_WINE ${USE_MSVC_WINE})
if(NOT USE_MSVC_WINE AND NOT "$ENV{USE_MSVC_WINE}" STREQUAL "")
  set(CACHE{USE_MSVC_WINE} TYPE BOOL VALUE "$ENV{USE_MSVC_WINE}")
endif()

if(CMAKE_HOST_WIN32 OR USE_MSVC_WINE)
  set(CACHE{VCPKG_CRT_LINKAGE} VALUE "dynamic")
  if(USE_MSVC_WINE)
    include(${CMAKE_SOURCE_DIR}/cmake/prep-msvc-wine.cmake)
  endif()

  if(NOT "${VCPKG_TARGET_TRIPLET}" STREQUAL "x86-windows-static-md")
    message(FATAL_ERROR "MSVC must used with triplet x86-windows-static-md")
  endif()

  chain("${VCPKG_ROOT}/scripts/toolchains/windows.cmake")

  set(CACHE{VCPKG_PLATFORM_TOOLSET} TYPE STRING VALUE v141)

  # https://learn.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=msvc-170
  # set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MD") # handled by target triplet...maybe

else()
  # https://github.com/microsoft/vcpkg/blob/master/triplets/community/x86-mingw-static-release.cmake
  # vcpkg/triplets/community/x86-mingw-static-release.cmake
  set(VCPKG_TARGET_TRIPLET x86-mingw-static-release) # '-dynamic' would make a separate "libdiscord-rpc.dll"

  # CMAKE_C_COMPILER, CMAKE_CXX_COMPILER, and CMAKE_RC_COMPILER are set by the triplet
  # CMAKE_C_FLAGS_INIT, CMAKE_CXX_FLAGS_INIT, and CMAKE_EXE_LINKER_FLAGS_INIT are set in ./toolchain_loader.cmake
endif()

set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_MANIFEST_MODE true)
set(VCPKG_MANIFEST_INSTALL true)

string(TOLOWER "${CMAKE_TOOLCHAIN_FILE}" cmake_toolchain_file)

# if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)

# if CMAKE_TOOLCHAIN_FILE is defined and not vcpkg, retain it as
# CMAKE_TOOLCHAIN_FILE_0. Then, assign vcpkg as the main toolchain.
if(NOT "${cmake_toolchain_file}" MATCHES "[\\/]vcpkg.cmake")
  # if USE_MSVC_WINE, do not chainload MingW32.cmake
  if(NOT (USE_MSVC_WINE AND "${cmake_toolchain_file}" MATCHES "[\\/]MingW32.cmake"))
    message(WARNING "USE_MSVC_WINE: ${USE_MSVC_WINE}")
    chain("${CMAKE_TOOLCHAIN_FILE}")
  endif()

  set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
endif()

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/toolchain_loader.cmake")
