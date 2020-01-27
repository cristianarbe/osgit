#!/bin/sh
# Copyright 2020 Cristian Ariza. All rights reserved.

set -eu

if test "$#" -eq 0; then
	cat /var/cache/vpk/packages
	exit 0
fi

option="$1"
shift

# shellcheck disable=SC2048
# shellcheck disable=SC2086
case "$option" in
	"-c") git --git-dir /var/cache/vpk/.git show $* ;;
	"-d") dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n ;;
	"-l") git --git-dir=/var/cache/vpk/.git log --oneline ;;
	"-v") apt-cache madison $* | sed 's/ | /=/' ;;
esac
