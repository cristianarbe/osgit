#!/bin/sh
# Copyright 2020 Cristian Ariza. All rights reserved.

case "$1" in
	"-d")
		pins="$(grep -n "$1" /etc/apt/preferences | cut -d ':' -f 1)"

		for pin in $pins; do
			end="$((pin + 2))"
			sed -i.bak -e "${pin},${end}d" "/etc/apt/preferences"
		done
		;;
	*)
		pkg_version="$(apt-cache policy "$1" | grep '\*\*' | cut -d ' ' -f 3)"

		{
			echo "package: $1"
			echo "Pin: version $pkg_version"
			echo "Pin-Priority: 1001"
		} >> /etc/apt/preferences
		;;
esac
