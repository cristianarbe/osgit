#!/bin/sh

set -eu

dpkg-query -Wf '${Package}=${Version}\n' | sort >"$VPKPATH"/packages
git commit -a -m "Sync" >/dev/null 2>&1

case "$1" in
  "-c")
    shift

    tmp="$(mktemp)"
    cp "$VKPATH"/packages "$tmp"

    git --git-dir "$VPKPATH"/.git --work-tree="$VPKPATH" revert --no-commit "$1"

    apt-get -q install $(comm -13 "$tmp" "$VKPATH"/packages)
    apt-get -q autoremove $(comm -23 "$tmp" "$1" "$VKPATH"/packages)

    dpkg-query -Wf '${Package}=${Version}\n' | sort > "$VPKPATH"/packages
    git commit -a -m "Revert $*" > /dev/null 2>&1
    ;;
  *)
    # shellcheck disable=SC2086
    # shellcheck disable=SC2048
    apt-get -q --autoremove purge $*
    dpkg-query -Wf '${Package}=${Version}\n' | sort > "$VPKPATH"/packages
    git commit -a -m "Remove $*" > /dev/null 2>&1
    ;;
esac
