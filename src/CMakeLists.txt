cmake_minimum_required(VERSION 3.10.0)
project(HCE.DRP VERSION 1.0.1)

if(UNIX AND NOT APPLE)
  set(LINUX TRUE)
endif()

if(NOT IS_DIRECTORY "${MSVC_ROOT}")
  set(MSVC_ROOT "/opt/msvc")
endif()

if(LINUX)
  # include_directories(
  # ${MSVC_ROOT}/vc/tools/msvc/14.44.35207/include/
  # ${MSVC_ROOT}/kits/10/Include/10.0.26100.0/shared/
  # ${MSVC_ROOT}/kits/10/Include/10.0.26100.0/ucrt/
  # ${MSVC_ROOT}/kits/10/Include/10.0.26100.0/um/
  # )
  set(BIN "${MSVC_ROOT}/bin/x64")
  exec_program(. ./msvcenv-native.sh)
endif()

# the name of the target operating system
set(CMAKE_SYSTEM_NAME Windows)

# region GitVersion
if("GitVersion")
  # Add directory of GitVersion to the cmake module path.
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

  # Now it can be included like this:
  include(GitVersion)
endif()

# endregion GitVersion

# CTest
include(CTest)
enable_testing()

set(i386 TRUE)
add_library(HCE.DRP main.cpp)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)
