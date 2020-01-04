#!/bin/sh

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

  if test -z "$2"; then
    echo "No packages will be $1"
    return 1
  fi

  echo "The following packages will be $1:"
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

# shellcheck disable=SC2068
apt_install() {
  apt_update

  available_versions "$1"
  log_fatal "apt-get update failed"

  apt-get -q install $@ ||
    log_fatal "apt-get install failed"
  }

apt_upgrade() {
  apt_update

  apt-get -q -y upgrade ||
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
