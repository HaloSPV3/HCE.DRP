# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only
cmake_minimum_required(VERSION 3.25)

# TODO: change incremented ENV variables to a single Key-Value list ENV variable e.g. "Key0=Value0:Key1=Value1"

# CMAKE_TOOLCHAIN_FILE and VCPKG_CHAINLOAD_TOOLCHAIN_FILE are not enough when we need to override parts of a toolchain
# Chain-load more than two toolchain files
# Useful when you have vcpkg and a toolchain file, but need to override a toolchain variable
function(chain toolchain_file)
  set(CMAKE_TOOLCHAIN_FILE_LIST "$ENV{CMAKE_TOOLCHAIN_FILE_LIST}")
  list(LENGTH CMAKE_TOOLCHAIN_FILE_LIST CMAKE_TOOLCHAIN_FILE_LIST_LENGTH)
  string(TOLOWER "${toolchain_file}" lowercase_toolchain_file)
  string(TOLOWER "${CMAKE_TOOLCHAIN_FILE_LIST}" lowercase_CMAKE_TOOLCHAIN_FILE_LIST)
  string(FIND "${lowercase_CMAKE_TOOLCHAIN_FILE_LIST}" "${lowercase_toolchain_file}" substringMatch)

  if("${lowercase_toolchain_file}" IN_LIST lowercase_CMAKE_TOOLCHAIN_FILE_LIST)
    set(isAlreadyChained true)
  else()
    set(isAlreadyChained false)
  endif()

  message(VERBOSE "  | BEFORE
  toolchain_file: ${toolchain_file}
  isAlreadyChained: ${isAlreadyChained}
  CMAKE_TOOLCHAIN_FILE_LIST_LENGTH: ${CMAKE_TOOLCHAIN_FILE_LIST_LENGTH}
  CMAKE_TOOLCHAIN_FILE_LIST: ${CMAKE_TOOLCHAIN_FILE_LIST}")

  if(isAlreadyChained)
    return() # noop; toolchain already chained
  endif()

  if(CMAKE_TOOLCHAIN_FILE_LIST_LENGTH EQUAL 0)
    set(CMAKE_TOOLCHAIN_FILE_LIST "${toolchain_file}")
  else()
    list(APPEND CMAKE_TOOLCHAIN_FILE_LIST "${toolchain_file}")
  endif()

  # assign CMAKE_TOOLCHAIN_FILE_LIST to ENV-scope
  set(ENV{CMAKE_TOOLCHAIN_FILE_LIST} "${CMAKE_TOOLCHAIN_FILE_LIST}")

  list(LENGTH CMAKE_TOOLCHAIN_FILE_LIST CMAKE_TOOLCHAIN_FILE_LIST_LENGTH)

  message(VERBOSE "  | AFTER
  toolchain_file: ${toolchain_file}
  CMAKE_TOOLCHAIN_FILE_LIST_LENGTH: ${CMAKE_TOOLCHAIN_FILE_LIST_LENGTH}
  ENV{CMAKE_TOOLCHAIN_FILE_LIST}: $ENV{CMAKE_TOOLCHAIN_FILE_LIST}")
endfunction()
