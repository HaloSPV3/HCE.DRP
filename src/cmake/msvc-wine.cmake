# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only

# ### NOTES
# - if link.exe hangs, try triplet x86-windows-lld

if(NOT USE_MSVC_WINE AND $ENV{USE_MSVC_WINE})
  set(USE_MSVC_WINE $ENV{USE_MSVC_WINE})
endif()

if(USE_MSVC_WINE)
  # find MSVC_ROOT
  if(NOT MSVC_ROOT)
    if(IS_DIRECTORY $ENV{MSVC_ROOT})
      set(MSVC_ROOT $ENV{MSVC_ROOT})
    endif()
  elseif(IS_DIRECTORY "/opt/msvc")
    set(MSVC_ROOT "/opt/msvc")
  else()
    message(FATAL_ERROR "MSVC_ROOT (e.g. /opt/msvc) not found!")
  endif() #

  # allow vcpkg to override windows triplets e.g.
  # /opt/msvc/cmake/vcpkg_triplets/x86-windows.cmake
  # /opt/msvc/cmake/vcpkg_triplets/x86-windows-clang.cmake
  # /opt/msvc/cmake/vcpkg_triplets/x86-windows-lld.cmake
  #
  # these may override the following variables:
  # VCPKG_TARGET_ARCHITECTURE
  # VCPKG_CRT_LINKAGE
  # VCPKG_LIBRARY_LINKAGE
  # VCPKG_ENV_PASSTHROUGH
  # VCPKG_ROOT_DIR (if falsey)
  # VCPKG_CHAINLOAD_TOOLCHAIN_FILE
  # VCPKG_LOAD_VCVARS_ENV (when VCPKG_CHAINLOAD_TOOLCHAIN_FILE is defined)
  # ENV{CC}   (sometimes)
  # ENV{CXX}  (sometimes)
  # ENV{PATH} (sometimes)
  if(NOT "${VCPKG_OVERLAY_TRIPLETS}" STREQUAL "${CMAKE_SOURCE_DIR}/cmake/triplets")
    message(WARNING "VCPKG_OVERLAY_TRIPLETS is being changed from \"${VCPKG_OVERLAY_TRIPLETS}\" to \"${CMAKE_SOURCE_DIR}/cmake/triplets/msvc-wine\".")
  endif()

  set(VCPKG_OVERLAY_TRIPLETS "${CMAKE_SOURCE_DIR}/cmake/triplets/msvc-wine")

else()
  message(Verbose "Not using MSVC-Wine")
endif()
