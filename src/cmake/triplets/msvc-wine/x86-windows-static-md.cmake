# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only

set(VCPKG_TARGET_ARCHITECTURE x86)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static) # set(VCPKG_LIBRARY_LINKAGE dynamic)

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

set(ENV{CC} cl.exe)
set(ENV{CXX} cl.exe)
set(ENV{PATH} "${MSVC_ROOT}/bin/x86:$ENV{PATH}")
set(VCPKG_LOAD_VCVARS_ENV ON) # Setting VCPKG_CHAINLOAD_TOOLCHAIN_FILE deactivates automatic vcvars setup so reenable it!
