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
# Constants
###########

WORKDIR="/var/cache/vpk"

###########
# Functions
###########

try() { "$@" || exit "$?"; }

usage() {
	printf 'vpkutils v2.0.0 (C) Cristian Ariza

usage: %s [-dls] [-c commitid] [-m package]

	-c  show COMMITID
	-l  show log
	-s  print package sizes
	-v  show PACKAGE available versions\n' "$(basename "$0")" >&2
	exit "${1-1}"
}

GIT() { git --git-dir "$WORKDIR"/.git "$@"; }

vpklist() { cat "$WORKDIR"/packages; }
vpklog() { GIT log; }
vpkshow() { GIT show "$@"; }
vpkversions() { apt-cache madison "$@" || return "$?" | sed 's/ | /=/g'; }

######
# Main
######

CMD="list"
while getopts "c:dlv:" c; do
	case "$c" in
	c)
		CMD="show"
		ARG="$OPTARG"
		;;
	d) set -x ;;
	l) CMD="log" ;;
	v)
		CMD="versions"
		ARG="$OPTARG"
		;;
	*) usage 1 ;;
	esac
done

case "$CMD" in
show | versions) eval "set -- $ARG" ;;
esac

try "vpk$CMD" "$@"

exit 0
