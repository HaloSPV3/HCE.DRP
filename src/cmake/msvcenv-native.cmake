# Copyright 2026 Noah Sherwin.
# SPDX-License-Identifier: GPL-3.0-only
# Adapted from msvc-native.sh | sets vcpkg target triplet; run before vcpkg
# Q: Is this necessary for HCE.DRP?
# A: No. This is only for auto-selecting a triplet based on the the architecture in the specified BIN directory's name.

# !/usr/bin/sh

# Copyright (c) 2019 Martin Storsjo
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# ####
# This is a script for setting up env variables for letting native tools
# find headers and libraries installed by the other msvc-wine scripts.
#
# To use this script, execute it like this:
# BIN=<path-to-msvc-wine-install>/bin/x64 . ./msvcenv-native.sh
# (Note the "." between the BIN variable and the msvcenv-native.sh script.)
# After executing this, you should be able to run clang-cl and lld-link
# without needing to configure paths manually anywhere.
# (If linking by invoking clang or clang-cl, instead of directly calling
# lld-link, it's recommended to use -fuse-ld=lld.)

if("${BIN}" STREQUAL "")
  message(SEND_ERROR "Set BIN to point to the directory (e.g. /opt/msvc/bin/x86) before launching")
else()
  set(ENV_SH "${BIN}/msvcenv.sh")

  if(NOT EXISTS "${ENV_SH}" AND NOT IS_DIRECTORY "${ENV_SH}")
    message(SEND_ERROR "\"${ENV_SH}\" doesn't exist")
  else()
    if(CMAKE_HOST_WIN32)
      set(_SEP ";")
    else()
      set(_SEP ":")
    endif()

    set(stdout)

    # INCLUDE="$(bash -c ". $ENV_SH && /usr/bin/env echo \"\$INCLUDE\"" | sed s/z://g | sed 's/\\/\//g')"
    execute_process(COMMAND "bash -c \". ${ENV_SH} && /usr/bin/env echo \\\"\$INCLUDE\\\"\" | sed s/z://g | sed 's/\\/\//g'")
    set(ENV{INCLUDE} "${stdout}")

    # LIB="$(bash -c ". $ENV_SH && /usr/bin/env echo \"\$LIB\"" | sed s/z://g | sed 's/\\/\//g')"
    execute_process(COMMAND "bash -c \". ${ENV_SH} && /usr/bin/env echo \\\"\$LIB\\\"\" | sed s/z://g | sed 's/\\/\//g'")
    set(ENV{LIB} "${stdout}")

    
    if(NOT DEFINED VCPKG_TARGET_TRIPLET)
      execute_process(COMMAND "bash -c \" . ${ENV_SH} && /usr/bin/env echo \\\"\$ARCH\\\"\"" OUTPUT_VARIABLE stdout)
      set(MSVCARCH "${stdout}")

      if("${MSVCARCH}" STREQUAL x86)
        set(TARGET_ARCH i686)
      elseif("${MSVCARCH}" STREQUAL x64)
        set(TARGET_ARCH x86_64)
      elseif("${MSVCARCH}" STREQUAL arm)
        set(TARGET_ARCH armv7)
      elseif("${MSVCARCH}" STREQUAL arm64)
        set(TARGET_ARCH aarch64)
      endif()

      set(CACHE{VCPKG_TARGET_TRIPLET} VALUE "${TARGET_ARCH}-windows-msvc")
    endif()
  endif()
endif()
