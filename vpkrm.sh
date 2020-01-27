#!/bin/sh

set -e

test -z "$VPKPATH" && echo "VPKPATH is not set" && exit 1

# shellcheck disable=SC2086
# shellcheck disable=SC2048
apt-get -q --autoremove purge $*
dpkg-query -Wf '${Package}=${Version}\n' | sort > "$VPKPATH"/packages
git commit -a -m "Remove $*" > /dev/null 2>&1
