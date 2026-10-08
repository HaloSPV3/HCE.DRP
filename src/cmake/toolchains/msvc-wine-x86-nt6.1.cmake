# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only

if(NOT IS_DIRECTORY "${MSVC_ROOT}")
  set(MSVC_ROOT "$ENV{MSVC_ROOT}")
endif()

include("${MSVC_ROOT}/cmake/toolchain-x86.cmake")

set(CMAKE_SYSTEM_VERSION 6.1)
set(CMAKE_AR ${MSVC_ROOT}/bin/x86/lib)
set(CMAKE_FIND_ROOT_PATH ${MSVC_ROOT}/bin/x86)
