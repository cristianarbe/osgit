# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Apt related commands

PREFIX="$(cd "$(dirname "$0")"/.. || exit; pwd)"

# shellcheck source=../lib/osgit/log.sh
. "$PREFIX"/lib/osgit/log.sh

apt_get_installed() {
  dpkg-query -Wf '${Package}=${Version}\n' | sort
}

apt_rm() {
  # shellcheck disable=SC2068
  apt-get -q --autoremove purge $@ ||
    log_fatal "apt-get purge failed"
  }

apt_show_packages() {
  if test "$#" -ne 2 || test -z "$2"; then
    return 1
  fi

  printf ":: The following packages will be $1:\\n$2\\n"
}

apt_install() {
  apt-get -q update ||
    log_fatal "apt-get update failed"

  # shellcheck disable=SC2068
  apt-get -q install $@ ||
    log_fatal "apt-get install failed"
  }

