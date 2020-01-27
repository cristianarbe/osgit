#!/bin/sh

set -eu

mkdir -p /var/cache/vpk
git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk init
dpkg-query -Wf '${Package}=${Version}\n' | sort > /var/cache/vpk/packages
git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk add packages -f
git --git-dir /var/cache/vpk/.git --work-tree=/var/cache/vpk commit -m "First commit"
