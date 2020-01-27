#!/bin/sh

set -eu

mkdir -p "$VPKPATH"
git --git-dir "$VPKPATH"/.git --work-tree="$VPKPATH" init
dpkg-query -Wf '${Package}=${Version}\n' | sort >"$VPKPATH"/packages
git --git-dir "$VPKPATH"/.git --work-tree="$VPKPATH" add packages -f
git --git-dir "$VPKPATH"/.git --work-tree="$VPKPATH" commit -m "First commit"
