#!/bin/sh

set -e

test -z "$VPKPATH" && echo "VPKPATH is not set" && exit 1

option="$1"
shift

# shellcheck disable=SC2048
# shellcheck disable=SC2086
case "$option" in
	"-d") dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n ;;
	"-g") git --git-dir="$VPKPATH"/.git log --oneline ;;
	"-l") cat "$VPKPATH"/packages ;;
	"-s") git --git-dir "$VPKPATH"/.git show $* ;;
	"-v") apt-cache madison $* | sed 's/ | /=/' ;;
esac
