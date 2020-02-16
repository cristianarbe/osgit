#!/bin/sh -u
#
# Copyright (c) 2019, Cristian Ariza
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Prints information about the vpk packages and repository

###########
# Functions
###########

try() { "$@" || exit "$?"; }

usage() {
	printf "pkutils v1.0.0 (C) Cristian Ariza

Usage: %s [-dhls] [-c COMMITID] [-m PACKAGE]

	-h  shows this menu
	-d  debug
	-c  show a COMMITID
	-l  show log
	-s  print package sizes
	-m  show packages versions" "$(basename "$0")" >&2
	exit "$1"
}

vpklist() { cat "$WORKDIR"/packages; }
vpklog() { git --git-dir "$WORKDIR"/.git log "$@" || return "$?"; }
vpkshow() { git --git-dir "$WORKDIR"/.git show "$@" || return "$?"; }
vpksizes() { dpkg-query -Wf '${Installed-Size}\t${Package}\n' || return "$?" | sort -n; }
vpkversions() { apt-cache madison "$@" || return "$?" | sed 's/ | /=/g'; }

######
# Main
######

WORKDIR="/var/cache/vpk"
action=

while [ "$#" -gt 0 ]; do
	arg="$1" && shift
	case "$arg" in
	"-h") usage 0 ;;
	"-d") set -x ;;
	"-c") action="show" ;;
	"-l") action="log" ;;
	"-s") action="sizes" ;;
	"-m") action="versions" ;;
	*) usage 1 ;;
	esac

	if [ -n "$action" ]; then
		break
	fi
done

${action:=list}

try "vpk$action" "$@"

exit 0
