#!/bin/sh
#
# Copyright 2019 Cristian Ariza
#
# See LICENSE file for license details.
#
# Installs packages and updates the git repo

WORKDIR="/var/cache/vpk"
GITDIR="/var/cache/vpk/.git"
PREFIX="$(
    cd "$(dirname "$0")"/.. || exit 1
    pwd
)"

# shellcheck disable=SC1090
. "$PREFIX"/lib/libvpkadd.sh || exit 1

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
		"-u")
			if test -n "$action"; then
				print_usg 1
			fi

			action=upgrade
			;;
		"-"*) print_usg 1 ;;
		*)
			if test -n "$action"; then
				print_usg 1
			fi

			action="install"

			packages="$packages $1"
			;;
		esac

		shift
	done

	if test ! -d "$GITDIR"; then
		try vpkinit $WORKDIR
		log "Initialised."
	fi

	try vpkupdate "$WORKDIR"
	log "Updated."

	case "$action" in
	install)
		try vpkinstall "$@"
        log "Installed packages $*."
		msg="Install $*"
		;;
	upgrade)
		try vpkupgrade
		msg="Upgrade packages"
        log "Upgraded."
		;;
    checkout)
        try vpkcheckout "$WORKDIR" "$id"
        msg="Checkout $id"
        log "Checked out $id."
    ;;
	esac

	try vpkcommit "$WORKDIR" "$msg"
}

print_usg() {
	cat <<'EOF' >&2
pkutils v0.7.0 (C) Cristian Ariza

Usage: vpkadd [-duv] [--help] [-c COMMITID] [PACKAGE]...
EOF
	exit "$1"
}

try() {
	if ! "$@"; then
		exit 1
	fi
}

log() {
	if test "$verbose" = true; then
		printf "%s\n" "$*"
	fi
}

main "$@"
