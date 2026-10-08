# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only
cmake_minimum_required(VERSION 3.10)

get_filename_component(SOURCE_CMAKE_TRIPLETS_MSVC_WINE_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(SOURCE_CMAKE_TRIPLETS_DIR "${SOURCE_CMAKE_TRIPLETS_MSVC_WINE_DIR}" DIRECTORY)
get_filename_component(SOURCE_CMAKE_DIR "${SOURCE_CMAKE_TRIPLETS_DIR}" DIRECTORY)

if(NOT EXISTS "${SOURCE_CMAKE_DIR}/cmake/toolchain_loader_chain.cmake")
  message(FATAL_ERROR "${SOURCE_CMAKE_DIR}/cmake/toolchain_loader_chain.cmake does not exist!")
endif()

include(${SOURCE_CMAKE_DIR}/cmake/toolchain_loader_chain.cmake)

if(NOT VCPKG_ROOT)
  set(VCPKG_ROOT $ENV{VCPKG_ROOT})
endif()
# TODO: chain call does not work; use list, CACHE variable, or ENV variables
# chain("${VCPKG_ROOT}/scripts/toolchains/windows.cmake") # chained in prep.cmake, instead

if("${MSVC_ROOT}" STREQUAL "" OR NOT MSVC_ROOT)
  set(MSVC_ROOT "$ENV{MSVC_ROOT}")

  if("${MSVC_ROOT}" STREQUAL "")
    set(MSVC_ROOT "/opt/msvc")
  endif()

  if(NOT EXISTS "${MSVC_ROOT}")
    message(FATAL_ERROR "Cannot find msvc-wine root! MSVC_ROOT: ${MSVC_ROOT}")
  endif()
endif()

set(ENV{VCPKG_TARGET_ARCHITECTURE} x86)
set(CACHE{VCPKG_TARGET_ARCHITECTURE} VALUE "x86" FORCE)
set(VCPKG_TARGET_ARCHITECTURE x86)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Windows)
set(ENV{PATH} "${MSVC_ROOT}/bin/${VCPKG_TARGET_ARCHITECTURE}:$ENV{PATH}")
set(ENV{CC} ${MSVC_ROOT}/bin/${VCPKG_TARGET_ARCHITECTURE}/cl)
set(ENV{CXX} ${MSVC_ROOT}/bin/${VCPKG_TARGET_ARCHITECTURE}/cl)
# ~~Setting VCPKG_CHAINLOAD_TOOLCHAIN_FILE deactivates automatic vcvars setup so reenable it!~~
# set(VCPKG_LOAD_VCVARS_ENV ON) # VCVars setup will throw an error when using msvc-wine
