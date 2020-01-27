#!/bin/sh

set -e

test -z "$VPKPATH" && echo "VPKPATH is not set" && exit 1

apt-get -q --autoremove purge $*
dpkg-query -Wf '${Package}=${Version}\n' | sort > "$VPKPATH"/packages
git commit -a -m "Remove $*" > /dev/null 2>&1
