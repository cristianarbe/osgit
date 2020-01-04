# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Apt related commands

<<<<<<< HEAD
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
=======
apt_update() {
  updated_recently="$(find /var/cache/apt/pkgcache.bin -mmin -5)"
  test -z "$updated_recently" && apt-get -q update
}

apt_get_installed() {
  dpkg-query -Wf '${Package}=${Version}\n'
}

apt_update_packages_and_git() {
  packages_update
  git_add_commit "$1"
}

apt_show_packages() {
  : "${2=}"
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

apt_show_packages() {
  if test "$#" -ne 2; then
    echo "No packages will be $1"
    return 1
  fi

  echo "The following packages will be $1:"
<<<<<<< HEAD
  __print_list "$2"
  return 0
}

apt_update() {
  updated_recently="$(find /var/cache/apt/pkgcache.bin -mmin -5)"
  if test -z "$updated_recently"; then
    apt-get -q update
  fi
}
=======
  list_print "$2"
  return 0
}

apt_propose_to_user() {
  if ! show_packages "installed" "$1" && ! show_packages "REMOVED" "$2"; then
    echo "Nothing to do."
    return
  fi

  printf "Do you want to continue? [y/N] " && read -r response

  case "$response" in
    y | Y | yes | YES) return 0 ;;
    *) return 1 ;;
  esac
}

# shellcheck disable=SC2068
apt_rm() {
  apt-get -q --autoremove purge $@ ||
    log_fatal "apt-get purge failed"
  }
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

apt_install() {
  case "$1" in
    *=*) ;;
    *)
      msg="$msg$(__available_versions "$1")"
      log_fatal "$msg"
      ;;
  esac

<<<<<<< HEAD
  apt_update ||
    log_fatal "apt-get update failed"
=======
  available_versions "$1"
  log_fatal "apt-get update failed"
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

  # shellcheck disable=SC2068
  apt-get -q install $@ ||
    log_fatal "apt-get install failed"
<<<<<<< HEAD
}
=======
  }
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

apt_upgrade() {
  apt_update

  apt-get -q -y upgrade ||
<<<<<<< HEAD
    log_fatal "apt-get upgrade failed"
  }


=======
    fatal "apt-get upgrade failed"
  }

apt_check_versions() {
  case "$1" in
    *=*)
      return 0
      ;;
    *)
      versions="$(apt-cache madison "$1" | tr -d ' ' | cut -d '|' -f 1,2 |
        sed 's/|/=/g' | sort | uniq)"

      if test -n "$versions"; then
        msg="Please specify a version, available versions are:"
        msg="${msg}$(print_list "$versions")"
      else
        msg="no available version for $1"
      fi

      return 1
      ;;
  esac
}

apt_get_version() {
  apt-cache policy "$1" | grep '\*\*' | cut -d ' ' -f 3
}
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be
