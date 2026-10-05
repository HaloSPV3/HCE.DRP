# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only
cmake_minimum_required(VERSION 3.10)

set(VCPKG_TARGET_ARCHITECTURE x86)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Windows)
set(ENV{PATH} "${MSVC_ROOT}/bin/${VCPKG_TARGET_ARCHITECTURE}:$ENV{PATH}")
set(ENV{CC} ${MSVC_ROOT}/bin/${VCPKG_TARGET_ARCHITECTURE}/cl)
set(ENV{CXX} ${MSVC_ROOT}/bin/${VCPKG_TARGET_ARCHITECTURE}/cl)
# ~~Setting VCPKG_CHAINLOAD_TOOLCHAIN_FILE deactivates automatic vcvars setup so reenable it!~~
# set(VCPKG_LOAD_VCVARS_ENV ON) # VCVars setup will throw an error when using msvc-wine

if(NOT VCPKG_ROOT_DIR)
  set(VCPKG_ROOT_DIR $ENV{VCPKG_ROOT})
endif()

chain(${VCPKG_ROOT_DIR}/scripts/toolchains/windows.cmake)

if(NOT MSVC_ROOT)
  set(MSVC_ROOT $ENV{MSVC_ROOT})

  if(MSVC_ROOT STREQUAL "")
    if(NOT CMAKE_HOST_WIN32)
    set(MSVC_ROOT "/opt/msvc")
    else()
    set(MSVC_ROOT )
    endif()
  endif()
endif()

