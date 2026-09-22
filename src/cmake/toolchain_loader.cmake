# Copyright 2026 Noah Sherwin
# SPDX-License-Identifier: GPL-3.0-only

# ########
# Check if this file CMAKE_TOOLCHAIN_FILE or VCPKG_CHAINLOAD_TOOLCHAIN_FILE
# ########

# string(REGEX MATCH "((?:^|[\\/])toolchain_loader.cmake)" IS_TOOLCHAIN_LOADER_PREPPED "${CMAKE_TOOLCHAIN_FILE}|${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
string(FIND "${CMAKE_TOOLCHAIN_FILE}|${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" "toolchain_loader.cmake" IS_TOOLCHAIN_LOADER_PREPPED)

if(NOT IS_TOOLCHAIN_LOADER_PREPPED)
  message(SEND_ERROR "This file should be loaded as a toolchain")
endif()

function(printToolchainVars cmake_toolchain_file_line)
  message(VERBOSE "  ${cmake_toolchain_file_line}
  CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}
  CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}
  CMAKE_SYSTEM_VERSION: ${CMAKE_SYSTEM_VERSION}
  CMAKE_CROSSCOMPILING: ${CMAKE_CROSSCOMPILING}
  TARGET: ${TARGET}
  CMAKE_C_COMPILER_TARGET: ${CMAKE_C_COMPILER_TARGET}
  CMAKE_CXX_COMPILER_TARGET: ${CMAKE_CXX_COMPILER_TARGET}
  TARGET_PREFIX: ${TARGET_PREFIX}
  CMAKE_C_COMPILER: ${CMAKE_C_COMPILER}
  CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}
  CMAKE_RANLIB: ${CMAKE_RANLIB}
  CMAKE_RC_COMPILER: ${CMAKE_RC_COMPILER}
  CMAKE_AR: ${CMAKE_AR}
  CMAKE_FIND_ROOT_PATH: ${CMAKE_FIND_ROOT_PATH}
  CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS: ${CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS}")
endfunction()

# our toolchain variables aren't preserved during the "project" function (why?). We must export them to environment variables.
set(CMAKE_TOOLCHAIN_FILE_0 "$ENV{CMAKE_TOOLCHAIN_FILE_0}")
set(CMAKE_TOOLCHAIN_FILE_1 "$ENV{CMAKE_TOOLCHAIN_FILE_1}")
set(CMAKE_TOOLCHAIN_FILE_2 "$ENV{CMAKE_TOOLCHAIN_FILE_2}")
set(CMAKE_TOOLCHAIN_FILE_3 "$ENV{CMAKE_TOOLCHAIN_FILE_3}")

message(VERBOSE
  "  CMAKE_TOOLCHAIN_FILE_0: ${CMAKE_TOOLCHAIN_FILE_0}
  CMAKE_TOOLCHAIN_FILE_1: ${CMAKE_TOOLCHAIN_FILE_1}
  CMAKE_TOOLCHAIN_FILE_2: ${CMAKE_TOOLCHAIN_FILE_2}
  CMAKE_TOOLCHAIN_FILE_3: ${CMAKE_TOOLCHAIN_FILE_3}
  CMAKE_TOOLCHAIN_FILE_4: ${CMAKE_TOOLCHAIN_FILE_4}")

# ########
# Chain-load additional toolchain files
# ########
if(NOT "${CMAKE_TOOLCHAIN_FILE_0}" STREQUAL "")
  include("${CMAKE_TOOLCHAIN_FILE_0}")
  printToolchainVars("CMAKE_TOOLCHAIN_FILE_0: ${CMAKE_TOOLCHAIN_FILE_0}")
endif()

if(CMAKE_TOOLCHAIN_FILE_1)
  include("${CMAKE_TOOLCHAIN_FILE_1}")
  printToolchainVars("CMAKE_TOOLCHAIN_FILE_1: ${CMAKE_TOOLCHAIN_FILE_1}")
endif()

if(CMAKE_TOOLCHAIN_FILE_2)
  include("${CMAKE_TOOLCHAIN_FILE_2}")
  printToolchainVars("CMAKE_TOOLCHAIN_FILE_2: ${CMAKE_TOOLCHAIN_FILE_2}")
endif()

if(CMAKE_TOOLCHAIN_FILE_3)
  message(ERROR "Why do you need a fourth chain-loaded toolchain file? Three should be more than enough!")
endif()

# hacky overrides

# Windows 7; MSBuildCMake.SDK's MinGW32.cmake toolchain file sets this to Windows 10; we don't want that!
set(CMAKE_SYSTEM_VERSION 6.1)

# CMAKE_C_COMPILER, CMAKE_CXX_COMPILER, and CMAKE_RC_COMPILER are set by the triplet
set(CMAKE_C_FLAGS_INIT "-static-libgcc")
set(CMAKE_CXX_FLAGS_INIT "-static-libgcc -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-static-libgcc -static-libstdc++")

# some triplets set this to 'dynamic'; we need 'static' lib-linking
set(VCPKG_LIBRARY_LINKAGE static)
