# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Manages the packages file

PREFIX="$(cd "$(dirname "$0")"/.. || exit; pwd)"
OSGITPATH="$PREFIX"/var/cache/osgit

# shellcheck source=../lib/osgit/apt.sh
. "$PREFIX"/lib/osgit/apt.sh
# shellcheck source=../lib/osgit/log.sh
. "$PREFIX"/lib/osgit/log.sh

packages_update(){
  apt_get_installed >"$OSGITPATH"/packages
}

packages_close(){
  if test "$#" -eq 0; then
    log_fatal "message not specified"
  fi

  packages_update
  git_add_commit "$1" > /dev/null 2>&1
}
