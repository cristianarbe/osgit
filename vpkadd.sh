#!/bin/sh

set -eu

dpkg-query -Wf '${Package}=${Version}\n' | sort >/var/cache/vpk/packages
git commit -a -m "Sync" >/dev/null 2>&1

apt-get -q update

case "$1" in
	"-c")
		# Checkout/rollback
		shift

		tmp="$(mktemp)"
		git show "$1":packages > "$tmp"

		apt-get -q install $(comm -13 /var/cache/vpk/packages "$tmp")
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
		apt-get -q install $*

		msg="Add $*"
		;;
esac

dpkg-query -Wf '${Package}=${Version}\n' | sort >/var/cache/vpk/packages
git commit -a -m "Rollback to $2" >/dev/null 2>&1
