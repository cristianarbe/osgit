# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Manages the packages file

PREFIX="$(cd "$(dirname "$0")"/.. || exit; pwd)"
OSGITPATH="$PREFIX"/var/cache/osgit

# shellcheck source=../lib/osgit/log.sh
. "$PREFIX"/lib/osgit/log.sh

pkg_get_installed() {
  dpkg-query -Wf '${Package}=${Version}\n' | sort -n
}

pkg_close(){
  if test "$#" -lt 1; then
    log_fatal "message not specified"
  fi

  packages_get_installed >"$OSGITPATH"/packages
  git --git-dir="$OSGITPATH"/.git add "$OSGITPATH"/packages -f
  git --git-dir="$OSGITPATH"/.git commit -m "$1" > /dev/null 2>&1
}
