#!/bin/sh
# Copyright 2020 Cristian Ariza. All rights reserved.

# TODO(3): Transform vpkrm to C

set -eu

if test ! -d /var/cache/vpk/.git; then
	mkdir -p /var/cache/vpk
	git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk init
fi

dpkg-query -Wf '${Package}=${Version}\n' | sort > /var/cache/vpk/packages
git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk commit -a -m "Sync" > /dev/null 2>&1 || true

case "$1" in
	"-c")
		# revert
		shift

		tmp="$(mktemp)"
		cp /var/cache/vpk/packages "$tmp"

		git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk revert --no-commit "$1"

		# shellcheck disable=SC2046
		apt-get -q install $(comm -13 "$tmp" /var/cache/vpk/packages)
		# shellcheck disable=SC2046
		apt-get -q autoremove $(comm -23 "$tmp" /var/cache/vpk/packages)

		dpkg-query -Wf '${Package}=${Version}\n' | sort > /var/cache/vpk/packages
		git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk commit -a -m "Revert $*" > /dev/null 2>&1
		;;
	*)
		# shellcheck disable=SC2086
		# shellcheck disable=SC2048
		apt-get -q --autoremove purge $*
		dpkg-query -Wf '${Package}=${Version}\n' | sort > /var/cache/vpk/packages
		git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk commit -a -m "Remove $*"
		;;
esac
