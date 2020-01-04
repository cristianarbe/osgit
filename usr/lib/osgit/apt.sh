# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Apt related commands

PREFIX="$(cd "$(dirname "$0")" || exit; pwd)"/..

# shellcheck source=../lib/osgit/log.sh
. "$PREFIX"/lib/osgit/log.sh

__available_versions() {
  versions="$(apt-cache madison "$1" | tr -d ' ' | cut -d '|' -f 1,2 |
    sed 's/|/=/g' | sort | uniq)"

  if test -z "$versions"; then
    echo "no available version for $1"
    return 1
  fi

  msg="available versions are:"
  echo "${msg}$(__list_print "$versions")"
  return 0
}

__print_list() {
  for package in $1; do
    printf "\\t%s\\n" "$package"
  done

  echo
}

apt_get_installed() {
  dpkg-query -Wf '${Package}=${Version}\n'
}

apt_rm() {
  # shellcheck disable=SC2068
  apt-get -q --autoremove purge $@ ||
    log_fatal "apt-get purge failed"
  }

apt_show_packages() {
  if test "$#" -ne 2; then
    echo "No packages will be $1"
    return 1
  fi

  echo "The following packages will be $1:"
  __print_list "$2"
  return 0
}

apt_update() {
  updated_recently="$(find /var/cache/apt/pkgcache.bin -mmin -5)"
  if test -z "$updated_recently"; then
    apt-get -q update
  fi
}

apt_install() {
  case "$1" in
    *=*) ;;
    *)
      msg="$msg$(__available_versions "$1")"
      log_fatal "$msg"
      ;;
  esac

  apt_update ||
    log_fatal "apt-get update failed"

  # shellcheck disable=SC2068
  apt-get -q install $@ ||
    log_fatal "apt-get install failed"
}

apt_upgrade() {
  apt_update

  apt-get -q -y upgrade ||
    log_fatal "apt-get upgrade failed"
  }


