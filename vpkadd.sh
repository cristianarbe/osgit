#!/bin/sh
#
# Copyright 2019 Cristian Ariza
#
# See LICENSE file for license details.
#
# Installs packages and updates the git repo

WORKDIR="/var/cache/vpk"

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

vpkupdate() {
	dpkg-query -Wf '${Package}=${Version}\n' | sort > "$WORKDIR"/packages || return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" add packages -f || return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" commit -m "Sync"
	quiet apt-get update || return "$?"
}

vpkinstall() { apt-get install "$@"; }

vpkupgrade() { apt-get upgrade -y; }

vpkcommit() {
	dpkg-query -Wf '${Package}=${Version}\n' | sort > "$WORKDIR"/packages || return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" add packages -f || return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" commit -m "$2" || return "$?"
}

vpkcheckout() {
	TMP="$(mktemp)"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" show \
		"$2":packages > "$TMP" || return "$?"

	eval "set -- $(comm -13 $WORKDIR/packages "$TMP")"
	apt-get install "$@" || return "$?"
	eval "set -- $(comm -23 $WORKDIR/packages "$TMP")"
	apt-get --autoremove purge "$@" || return "$?"

	rm "$TMP" || return "$?"
	unset "$TMP"
}

usage() {
	printf 'pkutils v0.7.0 (C) Cristian Ariza

Usage: %s [-duv] [--help] [-c COMMITID] [PACKAGE]...\n' "$(basename "$0")" >&2
	exit "$1"
}

while test "$#" -gt 0; do
	arg="$1" && shift
	case "$arg" in
		"-v") verbose=true ;;
		"-d") set -x ;;
		"--help") usage 0 ;;
		"-c")
			action="checkout"
			break
			;;
		"-u")
			action="upgrade"
			break
			;;
		"-"*) usage 1 ;;
		*)
			action="install"
			break
			;;
	esac
done

if test ! -d "$WORKDIR"/.git; then
	try vpkinit
fi

try vpkupdate

if test -n "$action"; then
	try "vpk$action" "$@"
	try vpkcommit "$action $*"
fi

exit 0
