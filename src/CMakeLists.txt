cmake_minimum_required(VERSION 4.4.3)

# if you run `dotnet build --verbosity diag` and encounter "Error: not a CMake
# build directory (missing CMakeCache.txt)", then the CMake build files are
# being generated in a different directory than what is expected by
# MSBuildCMake. Remove the `binaryDir` property from the CMake presets and try
# again to see the expected path.
#
# `string builddir = Path.Combine(IntermediateOutputDir, request.RID, request.ArchStr);`
# - IntermediateOutputDir: $(ArtifactsPath)/obj/$(MSBuildProjectName)/$(Configuration)
# - RID: win-x86
# - ArchStr: x86 (derived from RID)
# If the following is incorrect, edit `CMakePresets.json#configurePresets[?(@.name=="core-configure")].binaryDir`
# - .../artifacts/obj/DRP/debug_win-x86/win-x86/x86
# - .../artifacts/obj/DRP/release_win-x86/win-x86/x86 # If this is incorrect, edit `CMakePresets.json#configurePresets[?(@.name=="core-configure")].binaryDir`
#
# `string outputdir = Path.Combine(OutputDir, request.RID, "native");`
# - .../artifacts/bin/DRP/debug_win-x86/win-x86/native
# - .../artifacts/bin/DRP/release_win-x86/win-x86/native

# ? Can this be dropped to a lower version?
set(CMAKE_CXX_STANDARD 20)

# ########
# set up toolchains and more
# ########
include(cmake/toolchain_loader_chain.cmake)
include(cmake/MSBuildCMake.Sdk.cmake)
include(cmake/toolchain.cmake)
include(cmake/GitVersion.cmake) # Generate GitVersion variables
include(cmake/VersionInfo.cmake)

# unset output path of halocepresence.dll.a (archive of .o files)
# we don't want it in the release
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY)

message(VERBOSE
  "  vars:
  CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}
  VCPKG_CHAINLOAD_TOOLCHAIN_FILE: ${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}
  ENV{CMAKE_TOOLCHAIN_FILE_0}: $ENV{CMAKE_TOOLCHAIN_FILE_0}
  ENV{CMAKE_TOOLCHAIN_FILE_1}: $ENV{CMAKE_TOOLCHAIN_FILE_1}")

# ##############
# ## HCE.DRP
# ##############
project(DRP
  VERSION ${GITVERSION_AssemblySemVer}
  DESCRIPTION "Display your Halo: CE game status in your Discord profile."
  HOMEPAGE_URL https://github.com/HaloSPV3/HCE.DRP
  LANGUAGES C CXX
  SPDX_LICENSE gpl-3.0-only
)

# ##############
# ## toolchain checks
# ##############
message(VERBOSE
  "  vars:
  CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}
  CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}
  CMAKE_SYSTEM_VERSION: ${CMAKE_SYSTEM_VERSION}
  #
  CMAKE_C_COMPILER: ${CMAKE_C_COMPILER}
  CMAKE_C_FLAGS_INIT: ${CMAKE_C_FLAGS_INIT}
  CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}
  CMAKE_CXX_FLAGS_INIT: ${CMAKE_CXX_FLAGS_INIT}
  CMAKE_EXE_LINKER_FLAGS_INIT: ${CMAKE_EXE_LINKER_FLAGS_INIT}
  CMAKE_RC_COMPILER: ${CMAKE_RC_COMPILER}
  #
  VCPKG_TARGET_TRIPLET: ${VCPKG_TARGET_TRIPLET}
  CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}
  VCPKG_CHAINLOAD_TOOLCHAIN_FILE: ${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}
  ENV{CMAKE_TOOLCHAIN_FILE_0}: $ENV{CMAKE_TOOLCHAIN_FILE_0}")

# if you're using msvc-wine or mingw, you must include them outside of this file!
if(NOT CMAKE_SYSTEM_NAME STREQUAL Windows)
  message(FATAL_ERROR "Target system was changed from Windows! This is a Windows-only project! It is currently ${CMAKE_SYSTEM_NAME}")
endif()

if(NOT CMAKE_SYSTEM_VERSION STREQUAL "6.1")
  message(FATAL_ERROR "Target Windows version must be 6.1 (Windows 7). It is ${CMAKE_SYSTEM_VERSION}")
endif()

if(NOT(CMAKE_SYSTEM_PROCESSOR STREQUAL i686 OR CMAKE_SYSTEM_PROCESSOR STREQUAL x86))
  message(FATAL_ERROR "Target CPU Architecture was changed from i686(x86)! This is an i686-only project! It is currently ${CMAKE_SYSTEM_PROCESSOR}")
endif()

if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL static)
  message(WARNING "VCPKG_LIBRARY_LINKAGE should be static")
endif()

# MSBuildCmake.Sdk
if(NOT DEFINED NATIVE_OUTPUT_FOLDER)
  message(WARNING "This build was not started by .NET SDK. You will encounter issues!")
endif()

# ##############
# ## DRP
# ##############
add_library(DRP SHARED main.cpp)
set_target_properties(DRP PROPERTIES
  OUTPUT_NAME halocepresence
  PREFIX ""
)
target_sources(DRP PUBLIC FILE_SET HEADERS FILES send-presence.h)
target_sources(DRP PRIVATE DRP.rc DRP.manifest)

# set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)

VersionInfo_Generate(TARGET DRP
  PRODUCT_NAME "Halo: CE Discord Rich Presence module"
  PRODUCT_VERSION ${GITVERSION_AssemblySemVer} "${GITVERSION_InformationalVersion}"
  ORIGINAL_FILENAME DRP.dll
  INTERNAL_NAME DRP
  FILE_VERSION ${GITVERSION_AssemblySemFileVer} "${GITVERSION_AssemblySemFileVer}"
  FILE_DESCRIPTION "Display your Halo: CE game status in your Discord profile."
  FILE_FLAG_PRERELEASE $<BOOL:${GITVERSION_PreReleaseLabel}>
  LEGAL_COPYRIGHT "Copyright(C) 2026 Noah Sherwin"
  LANGUAGE 0x0409 1200 # en-us, UTF-16
)

# Set Windows-specific properties
if(WIN32 OR MINGW)
  target_compile_definitions(DRP PRIVATE DRP_EXPORTS)
endif()

# ##############
# ## discord-rpc
# ##############
# https://learn.microsoft.com/en-us/vcpkg/users/buildsystems/cmake-integration#using-libraries
# To find and use discord-rpc
# find_path(DISCORD_RPC_INCLUDE_DIR NAMES discord_rpc.h)
# target_include_directories(DRP PRIVATE ${DISCORD_RPC_INCLUDE_DIR})
find_path(DISCORD_RPC_INCLUDE_DIR NAMES discord_register.h discord_rpc.h REQUIRED)
target_include_directories(DRP PRIVATE "${DISCORD_RPC_INCLUDE_DIR}")

find_library(DISCORD_RPC_LIB discord-rpc REQUIRED)
target_link_libraries(DRP PRIVATE "${DISCORD_RPC_LIB}")

# ##############
# ## CPack
# ##############
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

# ##############
# ## Output
# ##############
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/../artifacts/")
install(TARGETS DRP
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/../artifacts/"
)

# ##############
# # CTest
# ##############
# include(CTest)
# enable_testing()

# ##############
# ## Docs, links, references
# ##############
# https://github.com/OpenSteamClient/MSBuildCMake/blob/master/NativeCompilationTask.cs
# https://github.com/OpenSteamClient/MSBuildCMake/blob/master/TestProject.Native/CMakeLists.txt
# https://github.com/microsoft/vcpkg/blob/master/triplets/community/x86-mingw-static-release.cmake

#
