#!/bin/sh

set -eu

option="$1"
shift

# shellcheck disable=SC2048
# shellcheck disable=SC2086
case "$option" in
	"-c") git --git-dir /var/cache/vpk/.git show $* ;;
	"-d") dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n ;;
	"-g") git --git-dir=/var/cache/vpk/.git log --oneline ;;
	"-l") cat /var/cache/vpk/packages ;;
	"-v") apt-cache madison $* | sed 's/ | /=/' ;;
esac
