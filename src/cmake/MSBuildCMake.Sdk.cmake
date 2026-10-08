# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only

set(OSXCROSS_TARGET_DIR "${OSXCROSS_TARGET_DIR}" CACHE STRING "OSXCross compiler target path (set from MSBuild)")
set(OSXCROSS_TARGET "${OSXCROSS_TARGET}" CACHE STRING "OSXCross target (set from MSBuild)")
set(BUILD_ARCH "${BUILD_ARCH}" CACHE STRING "Current arch being built (set from MSBuild)")
set(CustomBuildTaskRoot "${CustomBuildTaskRoot}" CACHE STRING "Path to CustomBuildTask (set from MSBuild)")
set(BUILD_PLATFORM_TARGET "${BUILD_PLATFORM_TARGET}" CACHE STRING "Current platform being built (set from MSBuild)")
set(BUILD_RID "${BUILD_RID}" CACHE STRING "Current RID being built, do not rely on this for any important logic! Does not support multi-arch builds (set from MSBuild)")
set(NATIVE_OUTPUT_FOLDER "${NATIVE_OUTPUT_FOLDER}" CACHE STRING "The place where extra build output should be placed (set from MSBuild)")

# NATIVE_OUTPUT_FOLDER may be set by cmake presets
if(NOT NATIVE_OUTPUT_FOLDER)
  message(WARNING "NATIVE_OUTPUT_FOLDER is undefined")
endif()

if(NOT CMAKE_HOST_WIN32 AND NOT USE_MSVC_WINE)
  if(NOT "${TARGET}" STREQUAL "i686-w64-mingw32")
    if(NOT NUGET_PACKAGES)
      # https://learn.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders
      if(NOT "$ENV{NUGET_PACKAGES}" STREQUAL "")
        set(NUGET_PACKAGES "$ENV{NUGET_PACKAGES}")
      elseif(CMAKE_HOST_APPLE OR CMAKE_HOST_LINUX)
        set(NUGET_PACKAGES "$ENV{HOME}/.nuget/packages")
      elseif(CMAKE_HOST_WIN32)
        set(NUGET_PACKAGES "$ENV{USERPROFILE}\\.nuget\\packages")
      endif()
    endif()

    # this is a toolchain; not a triplet
    # ______________________/msbuildcmake.sdk/1.1.0/crosscomp/MingW32.cmake
    chain("${NUGET_PACKAGES}/msbuildcmake.sdk/1.1.0/crosscomp/MingW32.cmake")
  endif()
endif()

include(cmake/MSBuildCMake.idesupport.cmake)
