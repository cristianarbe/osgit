#!/bin/sh

apt_update() {
  printf "Updating list of packages... "
  updated_recently="$(find /var/cache/apt/pkgcache.bin -mmin -5)"
  if test -z "$updated_recently"; then
    apt-get -q update >/dev/null
  fi
  printf "Done\\n"
}

get_installed() { dpkg-query -Wf '${Package}=${Version}\n'; }

update_packages_and_git() {
  get_installed >"$OSGIT_PROFILE"/packages
  add_commit "$1"
}

show_packages() {
  : "${2=}"

  if test -z "$2"; then
    echo "No packages will be $1"
    return 1
  fi

  echo "The following packages will be $1:"
  print_list "$2"
  echo
  return 0
}

propose_to_user() {
  anything_to_do=false

  show_packages "installed" "$1" && anything_to_do=true
  show_packages "REMOVED" "$2" && anything_to_do=true

  if ! "$anything_to_do"; then
    clean_exit "Nothing to do."
  fi

  printf "Do you want to continue? [y/N] " && read -r response

  case "$response" in
  y | Y | yes | YES) return 0 ;;
  *) return 1 ;;
  esac
}

# shellcheck disable=SC2068
apt_rm() {
  apt-get -q purge $@ ||
    fatal "apt-get purge failed"

  apt-get -q autoremove
}

# shellcheck disable=SC2068
apt_install() {
  apt_update

  available_versions "$1"

  apt-get -q install $@ ||
    fatal "apt-get install failed"
}

apt_upgrade() {
  apt_update

  apt-get -q upgrade -y ||
    fatal "apt-get upgrade failed"
}

available_versions() {
  case "$1" in
  *=*) ;;
  *)
    versions="$(apt-cache madison "$1" | tr -d ' ' | cut -d '|' -f 1,2 |
      sed 's/|/=/g' | sort | uniq)"

    if test -n "$versions"; then
      echo "Please specify a version, available versions are:" >&2
      print_list "$versions" >&2
      error
    else
      error "No available versions found for '$1'"
    fi

    ;;
  esac
}

get_package_version() {
  apt-cache policy "$1" | grep '\*\*' | cut -d ' ' -f 3
}
