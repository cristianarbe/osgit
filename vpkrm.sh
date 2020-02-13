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
# Installs packages and updates the git repo

###########
# Functions
###########

try() { "$@" || exit "$?"; }

quiet() {
	case "$verbose" in
		true) "$@" ;;
		*) "$@" > /dev/null ;;
	esac
}

vpkinit() {
	mkdir -p "$WORKDIR" || return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" init || return "$?"
}

vpkuninstall() { apt-get --autoremove purge "$@"; }

vpkcommit() {
	dpkg-query -Wf '${Package}=${Version}\n' | sort > "$WORKDIR"/packages ||
		return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" \
		add packages -f || return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" \
		commit -m "$2" || return "$?"
}

vpkrevert() {
	TMP="$(mktemp)"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" show \
		"$2":packages > "$TMP"

	# Apparently this is the corrent way to do it but not sure why
	eval "set -- $(comm -13 $WORKDIR/packages "$TMP")"
	apt-get install "$@"
	eval "set -- $(comm -23 $WORKDIR/packages "$TMP")"
	apt-get --autoremove purge "$@"

	rm "$TMP"
	unset "$TMP"
}

usage() {
	printf 'pkutils v0.7.0 (C) Cristian Ariza

Usage: %s [-dv] [--help] [-c COMMITID] [PACKAGE]...\n' "$(basename "$0")" >&2
	exit "$1"
}

######
# Main
######

WORKDIR="/var/cache/vpk"

while test "$#" -gt 0; do
	arg="$1" && shift
	case "$arg" in
		"-v") verbose=true ;;
		"-d") set -x ;;
		"--help") usage 0 ;;
		"-c")
			action="revert"
			break
			;;
		"-"*) usage 1 ;;
		*)
			action="uninstall"
			set -- "$arg" "$@"
			break
			;;
	esac
done

if test -z "$action"; then
	usage 1
fi

if test ! -d "$WORKDIR"/.git; then
	try vpkinit "$WORKDIR"
fi

try "vpk$action" "$@"
try vpkcommit "$action $*"

exit 0
