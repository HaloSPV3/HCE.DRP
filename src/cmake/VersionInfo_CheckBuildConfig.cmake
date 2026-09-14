# originally sourced from https://github.com/terminatorul/perl-ODBC/blob/4bdf09d9635d34084af4044fcc9a9f4ea529744a/cmake/VersionInfo_CheckBuildConfig.cmake
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

# Command line variables
#
#	GIT_EXECUTABLE
#	GIT_WORKING_TREE
#	TARGET_SOURCE_DIRECTORY
#	TARGET_NAME
#	TEMPLTE_FILE
#	RESOURCE_FILE
#
#	VERSIONINFO_PATCHED
#	VERSIONINFO_<TARGET>_PATCHED
#
#	VERSIONINFO_PRERELEASE
#	VERSIONINFO_<TARGET>_PRERELEASE
#
#	VERSIONINFO_PRIVATE_BUILD
#	VERSIONINFO_<TARGET>_PRVIATE_BUILD
#
#	VERSIONINFO_SPECIAL_BUILD
#	VERSIONINFO_<TARGET>_SPECIAL_BUILD

cmake_policy(SET CMP0007 NEW)

if(NOT DEFINED GIT_EXECUTABLE OR NOT DEFINED GIT_WORKING_TREE OR NOT TEMPLATE_FILE OR NOT RESOURCE_FILE OR NOT TARGET_SOURCE_DIRECTORY)
    foreach(VAR_NAME GIT_EXECUTABLE GIT_WORKING_TREE TEMPLATE_FILE RESOURCE_FILE TARGET_SOURCE_DIRECTORY)
	message(STATUS "${VAR_NAME}: ${${VAR_NAME}}")
    endforeach()

    message(SEND_ERROR "Missing command line definitions for VersionInfo cmake script.")
endif()

function(versioninfo_update_patched_flag LINE_OUTVAR)
    if(DEFINED ENV{VERSIONINFO_${TARGET_NAME}_PATCHED})
	set(IS_PATCHED "$ENV{VERSIONINFO_${TARGET_NAME}_PATCHED}")
    elseif(DEFINED ENV{VERSIONINFO_PATCHED})
	set(IS_PATCHED "$ENV{VERSIONINFO_PATCHED}")
    elseif(DEFINED VERSIONINFO_${TARGET_NAME}_PATCHED)
	set(IS_PATCHED "${VERSIONINFO_${TARGET_NAME}_PATCHED}")
    elseif(DEFINED VERSIONINFO_PATCHED)
	set(IS_PATCHED "${VERSIONINFO_PATCHED}")
    elseif(GIT_EXECUTABLE AND GIT_WORKING_TREE)
	# Beware it's possible for a target to have sources outside the ${TARGET_SOURCE_DIRECTORY}
	execute_process(COMMAND "${GIT_EXECUTABLE}" -C "${TARGET_SOURCE_DIRECTORY}" diff "--exit-code" "--quiet" "HEAD" RESULT_VARIABLE IS_PATCHED
	    COMMAND_ECHO NONE)

	if(NOT IS_PATCHED)
	    execute_process(COMMAND "${GIT_EXECUTABLE}" -C "${TARGET_SOURCE_DIRECTORY}" branch --remotes --contains HEAD
		OUTPUT_VARIABLE REMOTE_BRANCH_LIST OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE GIT_EXIT_CODE
		COMMAND_ECHO NONE)

	    if(GIT_EXIT_CODE)
		message(WARNING "git command error when checking current commit is published (remote) in call to VersionInfo_Generate()")
		set(IS_PATCHED TRUE)
	    else()
		if(REMOTE_BRANCH_LIST)
		    set(IS_PATCHED FALSE)
		else()
		    set(IS_PATCHED TRUE)
		endif()
	    endif()
	endif()
    else()
	set(IS_PATCHED FALSE)
    endif()

    if(IS_PATCHED)
	string(REPLACE "@{VS_FF_PATCHED}" "VS_FF_PATCHED" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
    else()
	string(REPLACE "@{VS_FF_PATCHED}" "0" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
    endif()

    set(${LINE_OUTVAR} "${${LINE_OUTVAR}}" PARENT_SCOPE)
endfunction()

function(versioninfo_update_prerelease_flag LINE_OUTVAR)
    if(DEFINED ENV{VERSIONINFO_${TARGET_NAME}_PRERELEASE})
	set(IS_PRERELEASE "$ENV{VERSIONINFO_${TARGET_NAME}_PRERELEASE}")
    elseif(DEFINED ENV{VERSIONINFO_PRERELEASE})
	set(IS_PRERELEASE "$ENV{VERSIONINFO_PRERELEASE}")
    elseif(DEFINED VERSIONINFO_${TARGET_NAME}_PRERELEASE)
	set(IS_PRERELEASE "${VERSIONINFO_${TARGET_NAME}_PRERELEASE}")
    elseif(DEFINED VERSIONINFO_PRERELEASE)
	set(IS_PRERELEASE "${VERSIONINFO_PRERELEASE}")
    elseif(GIT_EXECUTABLE AND GIT_WORKING_TREE)
	execute_process(COMMAND "${GIT_EXECUTABLE}" -C "${TARGET_SOURCE_DIRECTORY}" describe "--exact-match" "--tags" -- "HEAD"
	    OUTPUT_QUIET ERROR_VARIABLE GIT_ERROR_MESSAGE RESULT_VARIABLE GIT_EXIT_CODE
	    COMMAND_ECHO NONE)

	if(GIT_EXIT_CODE EQUAL "0")
	    set(IS_PRERELEASE FALSE)
	elseif(GIT_EXIT_CODE EQUAL "128")
	    set(IS_PRERELEASE TRUE)
	else()
	    message(WARNING "${GIT_ERROR_MESSAGE}\ngit command error when checking for tags pointing to current commit from call to VersionInfo_Generate()")
	    set(IS_PRERELEASE TRUE)
	endif()
    else()
	set(IS_PRERELEASE FALSE)
    endif()

    if(IS_PRERELEASE)
	string(REPLACE "@{VS_FF_PRERELEASE}" "VS_FF_PRERELEASE" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
    else()
	string(REPLACE "@{VS_FF_PRERELEASE}" "0" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
    endif()

    set(${LINE_OUTVAR} "${${LINE_OUTVAR}}" PARENT_SCOPE)
endfunction()

function(versioninfo_update_private_build LINE_OUTVAR REPLACE_FLAG)
    if(DEFINED ENV{VERSIONINFO_${TARGET_NAME}_PRIVATE_BUILD})
	set(PRIVATE_BUILD_STRING "$ENV{VERSIONINFO_${TARGET_NAME}_PRIVATE_BUILD}")
    elseif(DEFINED ENV{VERSIONINFO_PRIVATE_BUILD})
	set(PRIVATE_BUILD_STRING "$ENV{VERSIONINFO_PRIVATE_BUILD}")
    elseif(DEFINED VERSIONINFO_${TARGET_NAME}_PRIVATE_BUILD)
	set(PRIVATE_BUILD_STRING "${VERSIONINFO_${TARGET_NAME}_PRIVATE_BUILD}")
    elseif(DEFINED VERSIONINFO_PRIVATE_BUILD)
	set(PRIVATE_BUILD_STRING "${VERSIONINFO_PRIVATE_BUILD}")
    else()
	set(PRIVATE_BUILD_STRING)
    endif()

    if(REPLACE_FLAG)
	if(PRIVATE_BUILD_STRING)
	    string(REPLACE "@{VS_FF_PRIVATEBUILD}" "VS_FF_PRIVATEBUILD" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
	else()
	    string(REPLACE "@{VS_FF_PRIVATEBUILD}" "0" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
	endif()
    else()
	if(PRIVATE_BUILD_STRING)
	    string(REPLACE "@{PRIVATE_BUILD_LINE}" "            VALUE \"PrivateBuild\",       \"${PRIVATE_BUILD_STRING}\"" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
	else()
	    set(${LINE_OUTVAR})
	endif()
    endif()

    set(${LINE_OUTVAR} "${${LINE_OUTVAR}}" PARENT_SCOPE)
endfunction()

function(versioninfo_update_special_build LINE_OUTVAR REPLACE_FLAG)
    if(DEFINED ENV{VERSIONINFO_${TARGET_NAME}_SPECIAL_BUILD})
	set(SPECIAL_BUILD_STRING "$ENV{VERSIONINFO_${TARGET_NAME}_SPECIAL_BUILD}")
    elseif(DEFINED ENV{VERSIONINFO_SPECIAL_BUILD})
	set(SPECIAL_BUILD_STRING "$ENV{VERSIONINFO_SPECIAL_BUILD}")
    elseif(DEFINED VERSIONINFO_${TARGET_NAME}_SPECIAL_BUILD)
	set(SPECIAL_BUILD_STRING "${VERSIONINFO_${TARGET_NAME}_SPECIAL_BUILD}")
    elseif(DEFINED VERSIONINFO_SPECIAL_BUILD)
	set(SPECIAL_BUILD_STRING "${VERSIONINFO_SPECIAL_BUILD}")
    else()
	set(SPECIAL_BUILD_STRING)
    endif()

    if(REPLACE_FLAG)
	if(SPECIAL_BUILD_STRING)
	    string(REPLACE "@{VS_FF_SPECIALBUILD}" "VS_FF_SPECIALBUILD" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
	else()
	    string(REPLACE "@{VS_FF_SPECIALBUILD}" "0" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
	endif()
    else()
	if(SPECIAL_BUILD_STRING)
	    string(REPLACE "@{SPECIAL_BUILD_LINE}" "            VALUE \"SpecialBuild\",       \"${SPECIAL_BUILD_STRING}\"" ${LINE_OUTVAR} "${${LINE_OUTVAR}}")
	else()
	    set(${LINE_OUTVAR})
	endif()
    endif()

    set(${LINE_OUTVAR} "${${LINE_OUTVAR}}" PARENT_SCOPE)
endfunction()

file(READ "${TEMPLATE_FILE}" SOURCE_CONTENT)
string(REGEX MATCHALL "[^\n]*\n" SOURCE_CONTENT_LINES "${SOURCE_CONTENT}")

set(RESULT_CONTENT_LINES)

foreach(SOURCE_LINE ${SOURCE_CONTENT_LINES})
    if(SOURCE_LINE MATCHES "\\@\\{.*\\}")
	if(SOURCE_LINE MATCHES "\\@\\{VS_FF_PATCHED\\}")
	    versioninfo_update_patched_flag(SOURCE_LINE)
	endif()

	if(SOURCE_LINE MATCHES "\\@\\{VS_FF_PRERELEASE\\}")
	    versioninfo_update_prerelease_flag(SOURCE_LINE)
	endif()

	if(SOURCE_LINE MATCHES "\\@\\{VS_FF_PRIVATEBUILD\\}")
	    versioninfo_update_private_build(SOURCE_LINE TRUE)
	endif()

	if(SOURCE_LINE MATCHES "\\@\\{PRIVATE_BUILD_LINE\\}")
	    versioninfo_update_private_build(SOURCE_LINE FALSE)
	endif()

	if(SOURCE_LINE MATCHES "\\@\\{VS_FF_SPECIALBUILD\\}")
	    versioninfo_update_special_build(SOURCE_LINE TRUE)
	endif()

	if(SOURCE_LINE MATCHES "\\@\\{SPECIAL_BUILD_LINE\\}")
	    versioninfo_update_special_build(SOURCE_LINE FALSE)
	endif()
    endif()

    list(APPEND RESULT_CONTENT_LINES "${SOURCE_LINE}")
endforeach()

list(JOIN RESULT_CONTENT_LINES "" RESULT_CONTENT)

if(EXISTS "${RESOURCE_FILE}")
    file(READ "${RESOURCE_FILE}" RESOURCE_FILE_CONTENT)
else()
    set(RESOURCE_FILE_CONTENT)
endif()

if(NOT RESULT_CONTENT STREQUAL RESOURCE_FILE_CONTENT)
    file(WRITE "${RESOURCE_FILE}" "${RESULT_CONTENT}")
endif()
