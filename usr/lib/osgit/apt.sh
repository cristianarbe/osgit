# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Apt related commands

PREFIX="$(cd "$(dirname "$0")"/.. || exit; pwd)"

# shellcheck source=../lib/osgit/log.sh
. "$PREFIX"/lib/osgit/log.sh

__available_versions() {
  versions="$(apt-cache madison "$1" | tr -d ' ' | cut -d '|' -f 1,2 |
    sed 's/|/=/g' | sort | uniq)"

  if test -z "$versions"; then
    echo "no available versions for $1"
    return 1
  fi

  echo "need to specify a version, available versions are:"
  __print_list "$versions"
  return 0
}

__print_list() {
  for package in $1; do
    printf "\\t%s\\n" "$package"
  done

  echo
}

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
    echo "No packages will be $1"
    echo
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
  for package in $@; do
    case "$package" in
      *=*) ;;
      *)
        log_fatal "$(__available_versions "$package")"
        ;;
    esac
  done

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

