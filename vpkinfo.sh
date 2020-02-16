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
	printf 'vpkutils v1.0.0 (C) Cristian Ariza

Usage: %s [-dhls] [-c COMMITID] [-m PACKAGE]

	-h  shows this menu
	-d  debug
	-c  show a COMMITID
	-l  show log
	-s  print package sizes
	-m  show packages versions\n' "$(basename "$0")" >&2
	exit "${1-1}"
}

vpklist() { cat "$WORKDIR"/packages; }
vpklog() { git --git-dir "$WORKDIR"/.git log "$@" || return "$?"; }
vpkshow() { git --git-dir "$WORKDIR"/.git show "$@" || return "$?"; }
vpksizes() { dpkg-query -Wf '${Installed-Size}\t${Package}\n' || return "$?" | sort -n; }
vpkversions() { apt-cache madison "$@" || return "$?" | sed 's/ | /=/g'; }

######
# Main
######

ACTION="list"
WORKDIR="/var/cache/vpk"

while getopts "hdc:lsm:" c; do
	case "$c" in
	c)
		ACTION="show"
		ARG="$OPTARG"
		;;
	d) set -x ;;
	l) ACTION="log" ;;
	s) ACTION="sizes" ;;
	m)
		ACTION="versions"
		ARG="$OPTARG"
		;;
	*) usage 1 ;;
	esac
done

case "$ACTION" in
show | versions) eval "set -- $ARG" ;;
esac

try "vpk$ACTION" "$@"

exit 0
