cmake_minimum_required(VERSION 3.10.0)
project(HCE.DRP VERSION 1.0.1)

# the name of the target operating system
set(CMAKE_SYSTEM_NAME Windows)

if("GitVersion")
  # Add directory of GitVersion to the cmake module path.
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

  # Now it can be included like this:
  include(GitVersion)
endif()

# #endregion GitVersion
include(CTest)
enable_testing()

set(i386 TRUE)
add_library(HCE.DRP main.cpp)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

if(UNIX AND NOT APPLE)
  set(LINUX TRUE)
endif()

if(LINUX)
  include_directories(
    /opt/msvc/vc/tools/msvc/14.44.35207/include/
    /opt/msvc/kits/10/Include/10.0.26100.0/shared/
    /opt/msvc/kits/10/Include/10.0.26100.0/ucrt/
    /opt/msvc/kits/10/Include/10.0.26100.0/um/
  )
endif(LINUX)
