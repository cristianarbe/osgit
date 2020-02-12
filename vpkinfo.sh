#!/bin/sh
#
# Copyright 2019 Cristian Ariza
#
# See LICENSE file for license details.
#
# Installs packages and updates the git repo

WORKDIR="/var/cache/vpk"

try() { "$@" || exit "$?"; }

usage() {
	printf "pkutils v0.7.0 (C) Cristian Ariza

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

while test "$#" -gt 0; do
	arg="$1" && shift
	case "$arg" in
		"-h") usage 0 ;;
		"-d") set -x ;;
		"-c")
			action="show"
			break
			;;
		"-l")
			action="log"
			break
			;;
		"-s")
			action="sizes"
			break
			;;
		"-m")
			action="versions"
			break
			;;
		"-"*) usage 1 ;;
		*)
			action="list"
			break
			;;
	esac
done

if test -z "$action"; then
	action="list"
fi

try "vpk$action" "$@"

exit 0
