# originally sourced from https://github.com/terminatorul/perl-ODBC/blob/4bdf09d9635d34084af4044fcc9a9f4ea529744a/cmake/VersionInfo.cmake
# License: https://github.com/terminatorul/perl-ODBC/blob/4bdf09d9635d34084af4044fcc9a9f4ea529744a/LICENSE
# The Unlicense
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>

include_guard(DIRECTORY)

find_package(Git)

function(versioninfo_parse_version_string INPUT_STRING OUTVAR)
  string(REPLACE "." ";" INPUT_STRING "${INPUT_STRING}")
  string(REPLACE "," ";" INPUT_STRING "${INPUT_STRING}")
  list(LENGTH INPUT_STRING VERSION_PART_COUNT)

  if(VERSION_PART_COUNT EQUAL 0)
    message(SEND_ERROR "Bad version string")
  elseif(VERSION_PART_COUNT EQUAL 1)
    list(APPEND INPUT_STRING "0" "0" "0")
  elseif(VERSION_PART_COUNT EQUAL 2)
    list(APPEND INPUT_STRING "0" "0")
  elseif(VERSION_PART_COUNT EQUAL 3)
    list(APPEND INPUT_STRING "0")
  endif()

  set(${OUTVAR} "${INPUT_STRING}" PARENT_SCOPE)
endfunction()

function(versioninfo_check_git_working_tree DIRECTORY_NAME OUTVAR)
  execute_process(COMMAND "${GIT_EXECUTABLE}" -C "${DIRECTORY_NAME}" rev-parse --show-toplevel
    OUTPUT_QUIET
    ERROR_QUIET
    COMMAND_ECHO NONE
    RESULT_VARIABLE HAS_WORKING_TREE_RESULT)

  if(HAS_WORKING_TREE_RESULT EQUAL 0)
    set(${OUTVAR} TRUE PARENT_SCOPE)
  else()
    set(${OUTVAR} FALSE PARENT_SCOPE)
  endif()
endfunction()

function(versioninfo_setup_fileversion OUTVAR)
  set(VERSIONINFO_FILE_VERSION)

  get_target_property(TARGET_VERSION "${ARGS_MAP_TARGET}" VERSION)
  list(GET ARGS_MAP_FILE_VERSION 0 FILE_VERSION)

  foreach(VERSION_VAR IN ITEMS "FILE_VERSION" "TARGET_VERSION" "ARGS_MAP_VERSION" "PROJECT_VERSION" "CMAKE_PROJECT_VERSION")
    if(${VERSION_VAR})
      versioninfo_parse_version_string("${${VERSION_VAR}}" VERSIONINFO_FILE_VERSION)
      break()
    endif()
  endforeach()

  if(NOT VERSIONINFO_FILE_VERSION)
    message(SEND_ERROR "No FILE_VERSION specified or available for call to VersionInfo_Generate()")
    unset(${OUTVAR} PARENT_SCOPE)
  else()
    set(${OUTVAR} "${VERSIONINFO_FILE_VERSION}" PARENT_SCOPE)
  endif()
endfunction()

function(versioninfo_setup_productversion OUTVAR)
  set(VERSIONINFO_PRODUCT_VERSION)

  get_target_property(TARGET_VERSION "${ARGS_MAP_TARGET}" VERSION)
  list(GET ARGS_MAP_PRODUCT_VERSION 0 PRODUCT_VERSION)

  foreach(VERSION_VAR IN ITEMS "PRODUCT_VERSION" "ARGS_MAP_VERSION" "PROJECT_VERSION" "CMAKE_PROJECT_VERSION" "TARGET_VERSION")
    if(${VERSION_VAR})
      versioninfo_parse_version_string("${${VERSION_VAR}}" VERSIONINFO_PRODUCT_VERSION)
      break()
    endif()
  endforeach()

  if(NOT VERSIONINFO_PRODUCT_VERSION)
    message(SEND_ERROR "No PRODUCT_VERSION specified or available for call to VersionInfo_Generate()")
    unset(${OUTVAR} PARENT_SCOPE)
  else()
    set(${OUTVAR} "${VERSIONINFO_PRODUCT_VERSION}" PARENT_SCOPE)
  endif()
endfunction()

function(versioninfo_setup_fileflags OUTVAR)
  set(VERSIONINFO_FILE_FLAGS)

  if(DEFINED ARGS_MAP_FILE_FLAG_DEBUG)
    if(ARGS_MAP_FILE_FLAG_DEBUG)
      list(APPEND VERSIONINFO_FILE_FLAGS "VS_FF_DEBUG")
    endif()
  else()
    get_property(debug_configurations_list GLOBAL PROPERTY DEBUG_CONFIGURATIONS)
    get_property(generator_is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

    if(generator_is_multi_config)
      list(APPEND VERSIONINFO_FILE_FLAGS "$<IF:$<CONFIG:${debug_configurations_list},Debug,RelWithDebInfo>,VS_FF_DEBUG,0>")
    else()
      if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo" OR CMAKE_BUILD_TYPE IN_LIST debug_configurations_list)
        list(APPEND VERSIONINFO_FILE_FLAGS "VS_FF_DEBUG")
      endif()
    endif()
  endif()

  if(DEFINED ARGS_MAP_FILE_FLAG_PATCHED)
    if(ARGS_MAP_FILE_FLAG_PATCHED)
      list(APPEND VERSIONINFO_FILE_FLAGS "VS_FF_PATCHED")
    endif()
  else()
    list(APPEND VERSIONINFO_FILE_FLAGS "@{VS_FF_PATCHED}")
  endif()

  if(DEFINED ARGS_MAP_FILE_FLAG_PRERELEASE)
    if(ARGS_MAP_FILE_FLAG_PRERELEASE)
      list(APPEND VERSIONINFO_FILE_FLAGS "VS_FF_PRERELEASE")
    endif()
  else()
    if(NOT DEFINED VERSIONINFO_RELEASE_BUILD AND NOT DEFINED VERSIONINFO_${ARGS_MAP_TARGET}_RELEASE_BUILD)
      list(APPEND VERSIONINFO_FILE_FLAGS "@{VS_FF_PRERELEASE}")
    endif()
  endif()

  if(DEFINED ARGS_MAP_PRIVATE_BUILD)
    if(ARGS_MAP_PRIVATE_BUILD)
      list(APPEND VERSIONINFO_FILE_FLAGS "VS_FF_PRIVATEBUILD")
    endif()
  else()
    list(APPEND VERSIONINFO_FILE_FLAGS "@{VS_FF_PRIVATEBUILD}")
  endif()

  if(DEFINED ARGS_MAP_SPECIAL_BUILD)
    if(ARGS_MAP_SPECIAL_BUILD)
      list(APPEND VERSIONINFO_FILE_FLAGS "VS_FF_SPECIALBUILD")
    endif()
  else()
    list(APPEND VERSIONINFO_FILE_FLAGS "@{VS_FF_SPECIALBUILD}")
  endif()

  set(${OUTVAR} "${VERSIONINFO_FILE_FLAGS}" PARENT_SCOPE)
endfunction()

function(versioninfo_setup_fileos OUTVAR)
  if(ARGS_MAP_FILE_OS)
    set(FILE_OS "${ARGS_MAP_FILE_OS}")
  else()
    set(FILE_OS "VOS_NT_WINDOWS32")
  endif()

  set(${OUTVAR} "${FILE_OS}" PARENT_SCOPE)
endfunction()

function(versioninfo_setup_filetype_subtype TYPE_OUTVAR SUBTYPE_OUTVAR)
  get_target_property(TARGET_TYPE "${ARGS_MAP_TARGET}" TYPE)

  if(ARGS_MAP_FILE_TYPE)
    if(NOT ARGS_MAP_FILE_TYPE STREQUAL "VFT_UNKNOWN")
      if(TARGET_TYPE STREQUAL "EXECUTABLE" AND NOT ARGS_MAP_FILE_TYPE STREQUAL "VFT_APP")
        message(WARNING "Bad target file type for call to VersionInfo_Generate")
      endif()

      if((TARGET_TYPE STREQUAL "SHARED_LIBRARY" OR TARGET_TYPE STREQUAL "MODULE_LIBRARY") AND NOT ARGS_MAP_FILE_TYPE STREQUAL "VFT_DLL")
        message(WRNING "Bad target file type for call to VersionInfo_Generate")
      endif()
    endif()

    set(FILE_TYPE "${ARGS_MAP_FILE_TYPE}")
  else()
    if(TARGET_TYPE STREQUAL "EXECUTABLE")
      set(FILE_TYPE "VFT_APP")
    elseif(TARGET_TYPE STREQUAL "SHARED_LIBRARY" OR TARGET_TYPE STREQUAL "MODULE_LIBRARY")
      set(FILE_TYPE "VFT_DLL")
    elseif(TARGET_TYPE STREQUAL "STATIC_LIBRARY")
      message(WARNING "Static library providing VERSIONINFO resource, unable to select file type (VFT_APP or VFT_DLL). Specify FILE_TYPE explicitly.")

      # set(FILE_TYPE "VFT_STATIC_LIB")
      set(FILE_TYPE "VFT_UNKNOWN")
    else()
      set(FILE_TYPE "VFT_UNKNOWN")
    endif()
  endif()

  set(${TYPE_OUTVAR} "${FILE_TYPE}" PARENT_SCOPE)

  if(ARGS_MAP_FILE_SUBTYPE)
    set(${SUBTYPE_OUTVAR} "${ARGS_MAP_FILE_SUBTYPE}" PARENT_SCOPE)
  else()
    if(FILE_TYPE IN_LIST "VFT_DRV;VFT_FONT;VFT_VXD")
      message(WARNING "FILE_SUBTYPE argument expected for FILE_TYPE ${FILE_TYPE} in call to VersionInfo_Generate()")
    endif()

    set(${SUBTYPE_OUTVAR} "VFT2_UNKNOWN" PARENT_SCOPE)
  endif()
endfunction()

function(versioninfo_fill_fixed_block OUTVAR)
  list(JOIN VERSIONINFO_FILE_VERSION "," FILE_VERSION_STRING)
  list(JOIN VERSIONINFO_PRODUCT_VERSION "," PRODUCT_VERSION_STRING)
  list(LENGTH VERSIONINFO_FILE_FLAGS FILE_FLAGS_COUNT)

  if(FILE_FLAGS_COUNT EQUAL "0")
    set(FILE_FLAGS_STRING "0")
  elseif(FILE_FLAGS_COUNT EQUAL "1")
    set(FILE_FLAGS_STRING "${VERSIONINFO_FILE_FLAGS}")
  else()
    list(JOIN VERSIONINFO_FILE_FLAGS "|" FILE_FLAGS_STRING)
    set(FILE_FLAGS_STRING "(${FILE_FLAGS_STRING})")
  endif()

  list(APPEND ${OUTVAR}
    "FILEVERSION	${FILE_VERSION_STRING}"
    "PRODUCTVERSION	${PRODUCT_VERSION_STRING}"
    "FILEFLAGSMASK	VS_FFI_FILEFLAGSMASK"
    "FILEFLAGS	${FILE_FLAGS_STRING}"
    "FILEOS		${VERSIONINFO_FILE_OS}"
    "FILETYPE	${VERSIONINFO_FILE_TYPE}"
    "FILESUBTYPE	${VERSIONINFO_FILE_SUBTYPE}")

  set(${OUTVAR} "${${OUTVAR}}" PARENT_SCOPE)
endfunction()

function(versioninfo_fill_strings_block OUTVAR)
  list(APPEND ${OUTVAR} "    BLOCK \"StringFileInfo\"")
  list(APPEND ${OUTVAR} "    BEGIN")

  if(ARGS_MAP_VERSIONINFO_LANGUAGE)
    list(GET ARGS_MAP_VERSIONINFO_LANGUAGE 0 LANG_ID)
    list(GET ARGS_MAP_VERSIONINFO_LANGUAGE 1 CHARSET_ID)
    math(EXPR LANG_ID "${LANG_ID}" OUTPUT_FORMAT HEXADECIMAL)
    math(EXPR CHARSET_ID "${CHARSET_ID}" OUTPUT_FORMAT HEXADECIMAL)
    string(SUBSTRING "${LANG_ID}" 2 -1 LANG_ID)
    string(SUBSTRING "${CHARSET_ID}" 2 -1 CHARSET_ID)
    string(TOUPPER "${LANG_ID}" LANG_ID)
    string(TOUPPER "${CHARSET_ID}" CHARSET_ID)
    string(LENGTH "${LANG_ID}" LANG_ID_LENGTH)
    string(LENGTH "${CHARSET_ID}" CHARSET_ID_LENGTH)

    if(LANG_ID_LENGTH LESS "4")
      math(EXPR LANG_ID_PAD_LENGTH "4 - ${LANG_ID_LENGTH}" OUTPUT_FORMAT DECIMAL)
    else()
      set(LANG_ID_PAD_LENGTH "0")
    endif()

    if(CHARSET_ID_LENGTH LESS "4")
      math(EXPR CHARSET_ID_PAD_LENGTH "4 - ${CHARSET_ID_LENGTH}" OUTPUT_FORMAT DECIMAL)
    else()
      set(CHARSET_ID_PAD_LENGTH "0")
    endif()

    string(REPEAT "0" "${LANG_ID_PAD_LENGTH}" LANG_ID_PAD)
    string(REPEAT "0" "${CHARSET_ID_PAD_LENGTH}" CHARSET_ID_PAD)

    set(BLOCK_LANGUAGE "${LANG_ID_PAD}${LANG_ID}${CHARSET_ID_PAD}${CHARSET_ID}")
  else()
    set(BLOCK_LANGUAGE "040904E4") # Lang-ID: U.S. English, Charset: Multilingual
  endif()

  list(APPEND ${OUTVAR} "        BLOCK \"${BLOCK_LANGUAGE}\"")
  list(APPEND ${OUTVAR} "        BEGIN")

  if(ARGS_MAP_COMMENTS)
    list(APPEND ${OUTVAR} "            VALUE \"Comments\",	        \"${ARGS_MAP_COMMENTS}\"")
  endif()

  if(ARGS_MAP_COMPANY_NAME)
    list(APPEND ${OUTVAR} "            VALUE \"CompanyName\",        \"${ARGS_MAP_COMPANY_NAME}\"")
  else()
    list(APPEND ${OUTVAR} "            VALUE \"CompanyName\",        \"\"")
  endif()

  unset(FILE_DESCRIPTION)

  foreach(VAR_NAME IN ITEMS "ARGS_MAP_FILE_DESCRIPTION" "PROJECT_DESCRIPTION" "CMAKE_PROJECT_DESCRIPTION")
    if(${VAR_NAME})
      set(FILE_DESCRIPTION "${${VAR_NAME}}")
      break()
    endif()
  endforeach()

  if(NOT FILE_DESCRIPTION)
    message(SEND_ERROR "FILE_DESCRIPTION argument not specified and not available for call to VersionInfo_Generate()")
  endif()

  list(APPEND ${OUTVAR} "            VALUE \"FileDescription\",    \"${FILE_DESCRIPTION}\"")

  list(LENGTH ARGS_MAP_FILE_VERSION FILE_VERSION_LENGTH)

  if(FILE_VERSION_LENGTH GREATER 1)
    list(GET ARGS_MAP_FILE_VERSION 1 FILE_VERSION_STRING)
  else()
    list(JOIN VERSIONINFO_FILE_VERSION "." FILE_VERSION_STRING)
  endif()

  list(APPEND ${OUTVAR} "            VALUE \"FileVersion\",        \"${FILE_VERSION_STRING}\"")

  if(ARGS_MAP_ORIGINAL_FILENAME)
    cmake_path(GET ARGS_MAP_ORIGINAL_FILENAME FILENAME ORIGINAL_FILENAME)
  else()
    set(ORIGINAL_FILENAME "$<TARGET_FILE_NAME:${ARGS_MAP_TARGET}>")
  endif()

  if(ARGS_MAP_INTERNAL_NAME)
    cmake_path(GET ARGS_MAP_INTERNAL_NAME STEM INTERNAL_NAME)
  else()
    set(INTERNAL_NAME "$<PATH:GET_STEM,${ORIGINAL_FILENAME}>")
  endif()

  list(APPEND ${OUTVAR} "            VALUE \"InternalName\",       \"${INTERNAL_NAME}\"")

  if(ARGS_MAP_LEGAL_COPYRIGHT)
    list(APPEND ${OUTVAR} "            VALUE \"LegalCopyright\",     \"${ARGS_MAP_LEGAL_COPYRIGHT}\"")
  endif()

  if(ARGS_MAP_LEGAL_TRADEMARKS)
    list(LENGTH ARGS_MAP_LEGAL_TRADEMARKS LEGAL_TRADEMARKS_COUNT)

    if(LEGAL_TRADEMARKS_COUNT GREATER 1)
      set(LEGAL_TRADEMARK_INDEX 1)

      foreach(LEGAL_TRADEMARK_TEXT IN LISTS ARGS_MAP_LEGAL_TRADEMARKS)
        list(APPEND ${OUTVAR} "            VALUE \"LegalTrademarks${LEGAL_TRADEMARK_INDEX}\",   \"${LEGAL_TRADEMARK_TEXT}\"")
        math(EXPR LEGAL_TRADEMARK_INDEX "${LEGAL_TRADEMARK_INDEX} + 1" OUTPUT_FORMAT DECIMAL)
      endforeach()
    else()
      list(APPEND ${OUTVAR} "            VALUE \"LegalTrademarks\",    \"${ARGS_MAP_LEGAL_TRADEMARKS}\"")
    endif()
  endif()

  list(APPEND ${OUTVAR} "            VALUE \"OriginalFilename\",   \"${ORIGINAL_FILENAME}\"")

  if(DEFINED ARGS_MAP_PRIVATE_BUILD)
    if(ARGS_MAP_PRIVATE_BUILD)
      list(APPEND ${OUTVAR} "            VALUE \"PrivateBuild\",   \"${ARGS_MAP_PRIVATE_BUILD}\"")
    endif()
  else()
    list(APPEND ${OUTVAR} "@{PRIVATE_BUILD_LINE}")
  endif()

  unset(PRODUCT_NAME)

  foreach(VAR_NAME IN ITEMS "ARGS_MAP_PRODUCT_NAME" "PROJECT_NAME" "CMAKE_PROJECT_NAME" "ARGS_MAP_TARGET")
    if(${VAR_NAME})
      set(PRODUCT_NAME "${${VAR_NAME}}")
      break()
    endif()
  endforeach()

  list(APPEND ${OUTVAR} "            VALUE \"ProductName\",        \"${PRODUCT_NAME}\"")
  list(LENGTH ARGS_MAP_PRODUCT_VERSION PRODUCT_VERSION_LENGTH)

  if(PRODUCT_VERSION_LENGTH GREATER 1)
    list(GET ARGS_MAP_PRODUCT_VERSION 1 PRODUCT_VERSION_STRING)
  else()
    list(JOIN VERSIONINFO_PRODUCT_VERSION "." PRODUCT_VERSION_STRING)
  endif()

  list(APPEND ${OUTVAR} "            VALUE \"ProductVersion\",     \"${PRODUCT_VERSION_STRING}\"")

  if(DEFINED ARGS_MAP_SPECIAL_BUILD)
    if(ARGS_MAP_SPECIAL_BUILD)
      list(APPEND ${OUTVAR} "            VALUE\"SpecialBuild\",    \"${ARGS_MAP_SPECIAL_BUILD}\"")
    endif()
  else()
    list(APPEND ${OUTVAR} "@{SPECIAL_BUILD_LINE}")
  endif()

  list(APPEND ${OUTVAR} "        END")
  list(APPEND ${OUTVAR} "    END")

  set(${OUTVAR} "${${OUTVAR}}" PARENT_SCOPE)
endfunction()

function(versioninfo_fill_varinfo_block OUTVAR)
  if(ARGS_MAP_LANGUAGE)
    list(LENGTH ARGS_MAP_LANGUAGE LANGUAGE_COUNT)

    if(LANGUAGE_COUNT EQUAL 1)
      if(NOT ARGS_MAP_LANGUAGE STREQUAL "NONE")
        message(SEND_ERROR "Bad LANGUAGE argument in call to VersionInfo_Generate()")
      endif()

      return()
    endif()

    math(EXPR LANGUAGE_COUNT "${LANGUAGE_COUNT} % 2" OUTPUT_FORMAT DECIMAL)

    if(NOT LANGUAGE_COUNT EQUAL 0)
      message(WARNING "Bad LANGUAGE argument in call to VersionInfo_Generate()")
    endif()
  else()
    set(ARGS_MAP_LANGUAGE "0x409" "1252")
  endif()

  list(JOIN ARGS_MAP_LANGUAGE ", " VERSIONINFO_LANGUAGES)

  list(APPEND ${OUTVAR} "")
  list(APPEND ${OUTVAR} "    BLOCK \"VarFileInfo\"")
  list(APPEND ${OUTVAR} "    BEGIN")
  list(APPEND ${OUTVAR} "        VALUE \"Translation\", ${VERSIONINFO_LANGUAGES}")
  list(APPEND ${OUTVAR} "    END")

  set(${OUTVAR} "${${OUTVAR}}" PARENT_SCOPE)
endfunction()

function(versioninfo_fill_icon OUTVAR ICON_OUTVAR)
  if(ARGS_MAP_ICON)
    list(LENGTH ARGS_MAP_ICON ICON_LENGTH)

    if(ARGS_MAP_ICON_LENGTH GREATER 1)
      list(GET ARGS_MAP_ICON 0 ICON_ID)
      list(GET ARGS_MAP_ICON 1 ICON_FILENAME)
      cmake_path(SET ICON_FILENAME NORMALIZE "${ICON_FILENAME}")
    else()
      set(ICON_ID "IDI_ICON1")
      cmake_path(SET ICON_FILENAME NORMALIZE "${ARGS_MAP_ICON}")
    endif()

    get_target_property(target_source_directory ${ARGS_MAP_TARGET} SOURCE_DIR)
    cmake_path(ABSOLUTE_PATH ICON_FILENAME BASE_DIRECTORY "${target_source_directory}")
    list(APPEND ${OUTVAR} "")
    list(APPEND ${OUTVAR} "${ICON_ID} ICON \"${ICON_FILENAME}\"")

    set(${OUTVAR} "${${OUTVAR}}" PARENT_SCOPE)
    set(${ICON_OUTVAR} "${ICON_FILENAME}" PARENT_SCOPE)
  else()
    unset(${ICON_OUTVAR} PARENT_SCOPE)
  endif()
endfunction()

function(versioninfo_fill_content OUTPUT_FILENAME ICON_OUTVAR)
  set(RESOURCE_SCRIPT
    "#include <winver.h>"
    ""
    "VS_VERSION_INFO VERSIONINFO")
  versioninfo_fill_fixed_block(RESOURCE_SCRIPT)
  list(APPEND RESOURCE_SCRIPT "BEGIN")
  versioninfo_fill_strings_block(RESOURCE_SCRIPT)
  versioninfo_fill_varinfo_block(RESOURCE_SCRIPT)
  list(APPEND RESOURCE_SCRIPT "END")
  versioninfo_fill_icon(RESOURCE_SCRIPT ${ICON_OUTVAR})

  list(JOIN RESOURCE_SCRIPT "\n" RC_FILE_CONTENT)

  if(WIN32 OR CYGWIN OR MSYS OR MINGW OR DEFINED VERSIONINFO_NON_WIN32_GENERATE)
    file(GENERATE
      OUTPUT "${OUTPUT_FILENAME}"
      CONTENT "${RC_FILE_CONTENT}"
      TARGET "${ARGS_MAP_TARGET}"
      FILE_PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
      NEWLINE_STYLE WIN32)
  endif()

  set(${ICON_OUTVAR} "${${ICON_OUTVAR}}" PARENT_SCOPE)
endfunction()

set(VERSIONINFO_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(versioninfo_add_generate_step)
  if(VERSIONINFO_FILE_FLAGS MATCHES "\@\{.*\}")
    if(ARGS_MAP_RESOURCE_FILENAME)
      cmake_path(GET RESOURCE_FILE_NAME PARENT_PATH RESOURCE_FILE_DIR)
      cmake_path(GET RESOURCE_FILE_NAME STEM RESOURCE_FILE_BASENAME)
      cmake_path(GET RESOURCE_FILE_NAME EXTENSION RESOURCE_FILE_EXT)
      cmake_path(APPEND RESOURCE_TEMPLATE_NAME "${RESOURCE_FILE_DIR}" "${RESOURCE_FILE_BASENAME}.template.${RESOURCE_FILE_EXT}")
    else()
      if(generator_is_multi_config)
        set(RESOURCE_TEMPLATE_NAME "${TARGET_BINARY_DIRECTORY}/${ARGS_MAP_TARGET}_VersionInfo_$<CONFIG>.template.rc")
      else()
        set(RESOURCE_TEMPLATE_NAME "${TARGET_BINARY_DIRECTORY}/${ARGS_MAP_TARGET}_VersionInfo.template.rc")
      endif()
    endif()

    versioninfo_fill_content("${RESOURCE_TEMPLATE_NAME}" ICON_FILE_NAME)
    get_target_property(target_source_directory ${ARGS_MAP_TARGET} SOURCE_DIR)

    if(TARGET Git::Git)
      versioninfo_check_git_working_tree("${target_source_directory}" GIT_WORKING_TREE)
    else()
      set(GIT_WORKING_TREE FALSE)
    endif()

    if(DEFINED VERSIONINFO_PATCHED)
      set(VERSIONINFO_PATCHED_ARG "-DVERSIONINFO_PATCHED:BOOL=\"${VERSIONINFO_PATCHED}\"")
    else()
      set(VERSIONINFO_PATCHED_ARG)
    endif()

    if(DEFINED VERSIONINFO_${ARGS_MAP_TARGET}_PATCHED)
      set(VERSIONINFO_TARGET_PATCHED_ARG "-DVERSIONINFO_${ARGS_MAP_TARGET}_PATCHED:BOOL=\"${VERSIONINFO_${ARGS_MAP_TARGET}_PATCHED}\"")
    else()
      set(VERSIONINFO_TARGET_PATCHED_ARG)
    endif()

    if(DEFINED VERSIONINFO_PRERELEASE)
      set(VERSIONINFO_PRERELEASE_ARG "-DVERSIONINFO_PRERELEASE:BOOL=\"${VERSIONINFO_PRERELEASE}\"")
    else()
      set(VERSIONINFO_PRERELEASE_ARG)
    endif()

    if(DEFINED VERSIONINFO_${ARGS_MAP_TARGET}_PRERELEASE)
      set(VERSIONINFO_TARGET_PRERELEASE_ARG "-DVERSIONINFO_${ARGS_MAP_TARGET}_PRERELEASE:BOOL=\"${VERSIONINFO_${ARGS_MAP_TARGET}_PRERELEASE}\"")
    else()
      set(VERSIONINFO_TARGET_PRERELEASE_ARG)
    endif()

    if(DEFINED VERSIONINFO_PRIVATE_BUILD)
      set(VERSIONINFO_PRIVATE_BUILD_ARG "-DVERSIONINFO_PRIVATE_BUILD:STRING=\"${VERSIONINFO_PRIVATE_BUILD}\"")
    else()
      set(VERSIONINFO_PRIVATE_BUILD_ARG)
    endif()

    if(DEFINED VERSIONINFO_${ARGS_MAP_TARGET}_PRIVATE_BUILD)
      set(VERSIONINFO_TARGET_PRIVATE_BUILD_ARG "-DVERSIONINFO_${ARGS_MAP_TARGET}_PRIVATE_BUILD:STRING=\"${VERSIONINFO_${ARGS_MAP_TARGET}_PRIVATE_BUILD}\"")
    else()
      set(VERSIONINFO_TARGET_PRVIATE_BUILD_ARG)
    endif()

    if(DEFINED VERSIONINFO_SPECIAL_BUILD)
      set(VERSIONINFO_SPECIAL_BUILD_ARG "-DVERSIONINFO_SPECIAL_BUILD:STRING=\"${VERSIONINFO_SPECIAL_BUILD}\"")
    else()
      set(VERSIONINFO_SPECIAL_BUILD_ARG)
    endif()

    if(DEFINED VERSIONINFO_${ARGS_MAP_TARGET}_SPECIAL_BUILD)
      set(VERSIONINFO_TARGET_SPECIAL_BUILD_ARG "-DVERSIONINFO_${ARGS_MAP_TARGET}_SPECIAL_BUILD:STRING=\"${VERSIONINFO_${ARGS_MAP_TARGET}_SPECIAL_BUILD}\"")
    else()
      set(VERSIONINFO_TARGET_SPECIAL_BUILD_ARG)
    endif()

    if(WIN32 OR CYGWIN OR MSYS OR MINGW OR DEFINED VERSIONINFO_NON_WIN32_GENERATE)
      add_custom_target("${ARGS_MAP_TARGET}_CheckBuildConfig"
        BYPRODUCTS "${RESOURCE_FILE_NAME}"
        COMMENT "Checking for updates to VersionInfo flags..."
        COMMAND ${CMAKE_COMMAND}
        -DGIT_EXECUTABLE:PATH="${GIT_EXECUTABLE}"
        -DGIT_WORKING_TREE:BOOL="${GIT_WORKING_TREE}"
        -DTARGET_NAME:STRING="${ARGS_MAP_TARGET}"
        -DTARGET_SOURCE_DIRECTORY:PATH="${target_source_directory}"
        -DTEMPLATE_FILE:PATH="${RESOURCE_TEMPLATE_NAME}"
        -DRESOURCE_FILE:PATH="${RESOURCE_FILE_NAME}"
        ${VERSIONINFO_PATCHED_ARG}
        ${VERSIONINFO_TARGET_PATCHED_ARG}
        ${VERSIONINFO_PRERELEASE_ARG}
        ${VERSIONINFO_TARGET_PRERELEASE_ARG}
        ${VERSIONINFO_PRIVATE_BUILD_ARG}
        ${VERSIONINFO_TARGET_PRVIATE_BUILD_ARG}
        ${VERSIONINFO_SPECIAL_BUILD_ARG}
        ${VERSIONINFO_TARGET_SPECIAL_BUILD_ARG}
        -P "${VERSIONINFO_LIST_DIR}/VersionInfo_CheckBuildConfig.cmake")
    endif()
  else()
    versioninfo_fill_content("${RESOURCE_FILE_NAME}" ICON_FILE_NAME)
  endif()
endfunction()

# Usage:
#
# VersionInfo_Generate(TARGET <target-name>
# [ RESOURCE_FILE_NAME <file-name.rc> ]
# [ ICON [ <name-or-id> ] <icon-filename> ]
# [ VERSIONINFO_LANGUAGE <lang-ID> <charset-ID> ]
# [ COMPANY_NAME <company_name> ]
# [ COMMENTS <diagnostic-comment-text> ]
# [ PRODUCT_NAME <product-name> ]
# [ PRODUCT_VERSION <maj>[.<min>[.<rev>[.<build>]]] [ <version-string> ] ]
# [ ORIGINAL_FILENAME <original-filename> ]
# [ INTERNAL_NAME <internal-name> ]
# [ FILE_VERSION 1.0.8.2 [ <version-string> ] ]
# [ FILE_DESCRIPTION <description-string> ]
# [ FILE_FLAG_DEBUG <ON | OFF> ]
# [ FILE_FLAG_PATCHED <ON | OFF> ]
# [ FILE_FLAG_PRERELEASE <ON | OFF> ]
# [ PRIVATE_BUILD "privete build description" ]
# [ SPECIAL_BUILD "special build description" ]
# [ FILE_OS <file-os> ]
# [ FILE_TYPE <file-type> ]
# [ FILE_SUBTYPE <file-subtype> ]
# [ LEGAL_COPYRIGHT <copyright-text> ]
# [ LEGAL_TRADEMARKS <trademarks-text-line>... ]
# [ LANGUAGE NONE | <lang-code> <codepage> [ <lang-code> <codepage> ]... ])
#
# All the values above should follow the Microsoft resource compiler documentation on VERSIONINFO resource and ICON resource.
#
# Without FILE_VERSION and VERSION, the target property VERSION or the CMake variables PROJECT_VERSION or CMAKE_PROJECT_VERSION will be used as the file version.
# Without PRODUCT_VERSION and VERSION, the CMake variables PROJECT_VERSION or CMAKE_PROJECT_VERSION will be used as the product version, or the target property VERSION.
#
# If no version if given in the function call, and also no target property or global variable above can provide a version number, and error is emittedt.
# If no description is ginve in the function call, and also no project description is available in the CMake file, an error is emitted.
#
# If not given explicitly, the file flags VS_FF_PATCHED and VS_FF_PRERELEASE will be set at build time by default, depending on the status of your git working tree:
# - if the working tree has local changes or staged changes or local commits (not pushed to the remote), then file flag VS_FF_PATCHED will be set
# - if the working tree does not have a git tag pointing at the HEAD commit, then file flag VS_FF_PRERELEASE will be set
#
# If Git executable is not available at configure time, or the target source directory is not in a git working tree at that time, the above build-time checks are
# no longer performed, and the file is not marked as either PATCHED nor PRERELEASE.
#
# To disable the VS_FF_PRERELEASE flag (and create a release executable), you can set CMake variable VERSIONINFO_RELEASE_BUILD or VERSIONINFO_<TARGET>_RELEASE_BUILD.
#
# If not provided in the call to VersionInfo_Generate(), then the PRIVATE_BUILD and SPECIAL_BUILD strings can be given at build time using environment variables.
#
# Environment variables can also override the file flags at build time, as follows:
# - VERSIONINFO_<TARGET>_PATCHED and VERSIONINFO_PATCHED can be set to control the VS_FF_PATCHED flag
# - VERSIONINFO_<TARGET>_PRERELEASE and VERSIONINFO_PRERELEASE can be set to control the VS_FF_PRERELEASE flag
# - VERSIONINFO_<TARGET>_PRIVATE_BUILD and VERSIONINFO_PRIVATE_BUILD can be set to control the VS_FF_PRIVATEBUILD flag and the PrivateBuild string value
# - VERSIONINFO_<TARGET>_SPECIAL_BUILD and VERSIONINFO_SPECIAL_BUILD can be set to control the VS_FF_SPECIALBUILD flag and the SpecialBuild string value
#
# The declared language for the included version strings is English with code page 1252 by default. Trying to provide the same strings in multiple languages is not
# supported, although the Microsoft resource compiler has support for this. You should write a VERSIONINFO resource file manually if this is what you need.
#
# Use VERSIONINFO_LANGUAGE argument to specify the language for the included version strings like company and product name, or legal trademarks, and use the
# LANGUAGE argument to specify the languages supported by the target executable. The default language is English with code page 1252. If an executable or module does
# not make use of any language, like implmenting numerical functions only, you can set the LANGUAGE to NONE.
function(VersionInfo_Generate)
  set(ONE_ARG_KEYWORDS)
  list(APPEND ONE_ARG_KEYWORDS "COMPANY_NAME;PRODUCT_NAME;COMMENTS")
  list(APPEND ONE_ARG_KEYWORDS "TARGET;ORIGINAL_FILENAME;INTERNAL_NAME;FILE_DESCRIPTION")
  list(APPEND ONE_ARG_KEYWORDS "FILE_FLAG_DEBUG;FILE_FLAG_PATCHED;FILE_FLAG_PRERELEASE;PRIVATE_BUILD;SPECIAL_BUILD")
  list(APPEND ONE_ARG_KEYWORDS "FILE_OS;FILE_TYPE;FILE_SUBTYPE;LEGAL_COPYRIGHT")
  cmake_parse_arguments(PARSE_ARGV 0 ARGS_MAP "" "${ONE_ARG_KEYWORDS}" "ICON;LANGUAGE;PRODUCT_VERSION;FILE_VERSION;VERSION;LEGAL_TRADEMARKS;VERSIONINFO_LANGUAGE")

  if(ARGS_MAP_UNPARSED_ARGUMENTS)
    message(SEND_ERROR "Unknown options for call to VersionInfo_Generate(): ${ARGS_MAP_UNPARSED_ARGUMENTS}")
  endif()

  if(ARGS_MAP_KEYWORDS_MISSING_VALUES)
    message(SEND_ERROR "Missing values for following arguments in call to VersionInfo_Generate(): ${ARGS_MAP_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT ARGS_MAP_TARGET)
    message(SEND_ERROR "No TARGET specification for call to VersionInfo_Generate()")
  endif()

  if(ARGS_MAP_ICON)
    list(LENGTH ARGS_MAP_ICON ICON_ARGS_COUNT)

    if(NOT ICON_ARGS_COUNT EQUAL 1 AND NOT ICON_ARGS_COUNT EQUAL 2)
      message(SEND_ERROR "Bad arguments for ICON in call to VersionInfo_Generate()")
    endif()
  endif()

  if(ARGS_MAP_FILE_VERSION)
    list(LENGTH ARGS_MAP_FILE_VERSION FILE_VERSION_COUNT)

    if(NOT FILE_VERSION_COUNT EQUAL 1 AND NOT FILE_VERSION_COUNT EQUAL 2)
      message(SEND_ERROR "Bad arguments for FILE_VERSION in call to VersionInfo_Generate()")
    endif()
  endif()

  if(ARGS_MAP_PRODUCT_VERSION)
    list(LENGTH ARGS_MAP_PRODUCT_VERSION PRODUCT_VERSION_COUNT)

    if(NOT PRODUCT_VERSION_COUNT EQUAL 1 AND NOT PRODUCT_VERSION_COUNT EQUAL 2)
      message(SEND_ERROR "Bad arguments for PRODUCT_VERSION in call to VersionInfo_Generate()")
    endif()
  endif()

  if(ARGS_MAP_VERSION)
    list(LENGTH ARGS_MAP_VERSION VERSION_COUNT)

    if(NOT VERSION_COUNT EQUAL 1 AND NOT VERSION_COUNT EQUAL 2)
      message(SEND_ERROR "Bad arguments for VERSION in call to VersionInfo_Generate()")
    endif()
  endif()

  if(ARGS_MAP_VERSIONINFO_LANGUAGE)
    list(LENGTH ARGS_MAP_VERSIONINFO_LANGUAGE VERSIONINFO_LANGUAGE_COUNT)

    if(NOT VERSIONINFO_LANGUAGE_COUNT EQUAL 2)
      message(SEND_ERROR "Bad arguments for VERSIONINFO_LANGUAGE in call to VersionInfo_Generate()")
    endif()
  endif()

  versioninfo_setup_fileversion(VERSIONINFO_FILE_VERSION)
  versioninfo_setup_productversion(VERSIONINFO_PRODUCT_VERSION)
  versioninfo_setup_fileflags(VERSIONINFO_FILE_FLAGS)
  versioninfo_setup_fileos(VERSIONINFO_FILE_OS)
  versioninfo_setup_filetype_subtype(VERSIONINFO_FILE_TYPE VERSIONINFO_FILE_SUBTYPE)

  get_target_property(TARGET_BINARY_DIRECTORY ${ARGS_MAP_TARGET} BINARY_DIR)
  get_property(generator_is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

  if(ARGS_MAP_RESOURCE_FILENAME)
    cmake_path(SET RESOURCE_FILE_NAME NORMALIZE "${ARGS_MAP_RESOURCE_FILE_NAME}")
    cmake_path(ABSOLUTE_PATH RESOURCE_FILE_NAME BASE_DIRECTORY "${TARGET_BINARY_DIRECTORY}")
  else()
    if(generator_is_multi_config)
      cmake_path(APPEND RESOURCE_FILE_NAME "${TARGET_BINARY_DIRECTORY}" "${ARGS_MAP_TARGET}_VersionInfo_$<CONFIG>.rc")
    else()
      cmake_path(APPEND RESOURCE_FILE_NAME "${TARGET_BINARY_DIRECTORY}" "${ARGS_MAP_TARGET}_VersionInfo.rc")
    endif()
  endif()

  versioninfo_add_generate_step()

  if(WIN32 OR CYGWIN OR MSYS OR MINGW)
    target_sources("${ARGS_MAP_TARGET}" PRIVATE "${RESOURCE_FILE_NAME}")

    if(ICON_FILE_NAME)
      if(ARGS_MAP_RESOURCE_FILENAME OR NOT generator_is_multi_config)
        set_property(SOURCE "${RESOURCE_FILE_NAME}" APPEND PROPERTY OBJECT_DEPENDS "${ICON_FILE_NAME}")
      else()
        foreach(CONFIG_NAME_STRING IN LISTS CMAKE_CONFIGURATION_TYPES)
          cmake_path(APPEND PER_CONFIG_VERSION_INFO_FILE "${TARGET_BINARY_DIRECTORY}" "${ARGS_MAP_TARGET}_VersionInfo_${CONFIG_NAME_STRING}.rc")
          set_property(SOURCE "${PER_CONFIG_VERSION_INFO_FILE}" APPEND PROPERTY OBJECT_DEPENDS "${ICON_FILE_NAME}")
        endforeach()
      endif()
    endif()
  endif()
endfunction()
