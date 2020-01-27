#!/bin/sh

set -eu

dpkg-query -Wf '${Package}=${Version}\n' | sort >/var/cache/vpk/packages
git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk commit -a -m "Sync" >/dev/null 2>&1 || true

apt-get -q update

if test "$#" -eq 0; then
	exit 0
fi

case "$1" in
"-c")
	# Checkout/rollback
	shift

	tmp="$(mktemp)"
	git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk show "$1":packages >"$tmp"

	# shellcheck disable=SC2046
	apt-get -q install $(comm -13 /var/cache/vpk/packages "$tmp")
	# shellcheck disable=SC2046
	apt-get -q autoremove $(comm -23 /var/cache/vpk/packages "$tmp")

	msg="Rollback to $2"
	;;
"-u")
	# Upgrade
	apt-get -q upgrade

	msg="Upgrade"
	;;
*)
	# Install
	# shellcheck disable=SC2086
	# shellcheck disable=SC2048
	apt-get -q install $*

	msg="Add $*"
	;;
esac

dpkg-query -Wf '${Package}=${Version}\n' | sort >/var/cache/vpk/packages
git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk commit -a -m "$msg" >/dev/null 2>&1
