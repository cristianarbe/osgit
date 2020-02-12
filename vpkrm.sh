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

vpkuninstall() { apt-get --autoremove purge "$@"; }

vpkcommit() {
	dpkg-query -Wf '${Package}=${Version}\n' | sort > "$WORKDIR"/packages || return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" add packages -f || return "$?"
	quiet git --git-dir="$WORKDIR"/.git --work-tree="$WORKDIR" commit -m "$2" || return "$?"
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
