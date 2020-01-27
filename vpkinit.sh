#!/bin/sh

set -e

mkdir -p "$VPKPATH"
git --git-dir "$VPKPATH"/.git --work-tree="$VPKPATH" init
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n > "$VPKPATH"/packages
git --git-dir "$VPKPATH"/.git --work-tree="$VPKPATH" add "$VPKPATH"/packages
git --git-dir "$VPKPATH"/.git --work-tree="$VPKPATH" commit -m "$1"
