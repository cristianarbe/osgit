# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Manages the packages file

PREFIX="$(cd "$(dirname "$0")"/.. || exit; pwd)"
OSGITPATH="$PREFIX"/var/cache/osgit

# shellcheck source=../lib/osgit/log.sh
. "$PREFIX"/lib/osgit/log.sh
# shellcheck source=../lib/osgit/git.sh
. "$PREFIX"/lib/osgit/git.sh

pkgs_get_installed() {
  dpkg-query -Wf '${Package}=${Version}\n' | sort -n
}

pkgs_close(){
  if test "$#" -lt 1; then
    log_fatal "message not specified"
  fi

  pkgs_get_installed >"$OSGITPATH"/packages
  git_path add packages -f
  git_path commit -m "$1" > /dev/null 2>&1
}
