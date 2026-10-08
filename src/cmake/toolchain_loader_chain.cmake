# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only
cmake_minimum_required(VERSION 3.25)

# TODO: change incremented ENV variables to a single Key-Value list ENV variable e.g. "Key0=Value0:Key1=Value1"

# CMAKE_TOOLCHAIN_FILE and VCPKG_CHAINLOAD_TOOLCHAIN_FILE are not enough when we need to override parts of a toolchain
# Chain-load more than two toolchain files
# Useful when you have vcpkg and a toolchain file, but need to override a toolchain variable
function(chain toolchain_file)
  if("$ENV{CMAKE_TOOLCHAIN_FILE_0}" STREQUAL "${toolchain_file}"
    OR "$ENV{CMAKE_TOOLCHAIN_FILE_1}" STREQUAL "${toolchain_file}"
    OR "$ENV{CMAKE_TOOLCHAIN_FILE_2}" STREQUAL "${toolchain_file}"
    OR "$ENV{CMAKE_TOOLCHAIN_FILE_3}" STREQUAL "${toolchain_file}"
    OR "$ENV{CMAKE_TOOLCHAIN_FILE_4}" STREQUAL "${toolchain_file}")
    return() # noop; toolchain already chained
  endif()

  # todo: investigate if PARENT_SCOPE parameter allows for non-ENV vars to propagate
  if("$ENV{CMAKE_TOOLCHAIN_FILE_0}" STREQUAL "")
    set(ENV{CMAKE_TOOLCHAIN_FILE_0} "${toolchain_file}")
  elseif("$ENV{CMAKE_TOOLCHAIN_FILE_1}" STREQUAL "")
    set(ENV{CMAKE_TOOLCHAIN_FILE_1} "${toolchain_file}")
  elseif("$ENV{CMAKE_TOOLCHAIN_FILE_2}" STREQUAL "")
    set(ENV{CMAKE_TOOLCHAIN_FILE_2} "${toolchain_file}")
  elseif("$ENV{CMAKE_TOOLCHAIN_FILE_3}" STREQUAL "")
    set(ENV{CMAKE_TOOLCHAIN_FILE_3} "${toolchain_file}")
  elseif("$ENV{CMAKE_TOOLCHAIN_FILE_4}" STREQUAL "")
    set(ENV{CMAKE_TOOLCHAIN_FILE_4} "${toolchain_file}")
  else()
    message(FATAL_ERROR is this overkill?)
  endif()

  message(VERBOSE
    "  toolchain_file: ${toolchain_file}
  ENV{CMAKE_TOOLCHAIN_FILE_0}: $ENV{CMAKE_TOOLCHAIN_FILE_0}
  ENV{CMAKE_TOOLCHAIN_FILE_1}: $ENV{CMAKE_TOOLCHAIN_FILE_1}
  ENV{CMAKE_TOOLCHAIN_FILE_2}: $ENV{CMAKE_TOOLCHAIN_FILE_2}
  ENV{CMAKE_TOOLCHAIN_FILE_3}: $ENV{CMAKE_TOOLCHAIN_FILE_3}
  ENV{CMAKE_TOOLCHAIN_FILE_4}: $ENV{CMAKE_TOOLCHAIN_FILE_4}")
endfunction()
