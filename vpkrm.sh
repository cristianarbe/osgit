#!/bin/sh
#
# Copyright 2019 Cristian Ariza
#
# See LICENSE file for license details.
#
# Uninstalls packages and updates the git repo

#include pathnames.sh
#include vpkrmh.sh

main() {
	while test "$#" -gt 0; do
		case "$1" in
		"-v") verbose=true ;;
		"-d") set -x ;;
		"--help") print_usg 0 ;;
		"-c")
			if test -n "$action"; then
				print_usg 1
			fi

			action=checkout
			shift
			id="$1"
			;;
		"-"*) print_usg 1 ;;
		*)
			if test -n "$action"; then
				print_usg 1
			fi

			action="uninstall"

			packages="$packages $1"
			;;
		esac

		shift
	done

	if test ! -d "$_GIT_DIR"; then
		try vpkinit $_WORK_DIR
		log "Initialised."
	fi

	case "$action" in
	uninstall)
		try vpkinstall "$@"
        log "Installed packages $*."
		msg="Install $*"
		;;
	esac

	try vpkcommit "$_WORK_DIR" "$msg"
}

print_usg() {
	cat <<'EOF' >&2
pkutils v0.7.0 (C) Cristian Ariza

Usage: vpkrm [-dv] [--help] [-c COMMITID] [PACKAGE]...
EOF
	exit "$1"
}

try() {
	if ! "$@"; then
		exit 1
	fi
}

log() {
	if "$verbose"; then
		printf "%s\n" "$*"
	fi
}

main "$@"
