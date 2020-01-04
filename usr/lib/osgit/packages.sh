# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Manages the packages file

PREFIX="$(cd "$(dirname "$0")" || exit; pwd)"/../..
OSGITPATH="$PREFIX"/var/cache/osgit

# shellcheck source=../lib/osgit/apt.sh
. "$PREFIX"/lib/osgit/apt.sh

__check_root() {
  test "$(id -u)" -ne 0 && log_fatal "this option must be run as root"
}

packages_update(){
  get_installed >"$OSGITPATH"/packages
}

packages_open(){
  __check_root
  git_make_this_master
}

packages_close(){
  test "$#" -eq 0 && log_fatal "message not specified"
  packages_update
  git_add_commit "$1"
}
