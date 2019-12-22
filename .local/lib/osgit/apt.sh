#!/bin/sh

apt_update() {
  printf "Updating list of packages... "
  if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -5)" ]; then
    sudo apt-get -q update >/dev/null
  fi
  printf "Done\\n"
}

get_installed() { dpkg-query -Wf '${Package}=${Version}\n'; }

update_packages_and_git() {
  get_installed >"$OSGIT_PROFILE"/packages
  add_commit "$1"
}

show_packages() {
  if test -z "$2"; then
    echo "No packages will be $1"
    return
  fi

  echo "The following packages will be $1:"
  print_list "$2"
}

propose_to_user() {
  show_packages "installed" "$1"
  echo ""
  show_packages "REMOVED" "$2"

  printf "Do you want to continue? [y/N] " && read -r response

  case "$response" in
  y | Y | yes | YES) return 0 ;;
  *) return 1 ;;
  esac
}

# shellcheck disable=SC2068
apt_rm() {
  sudo apt-get -q purge $@ ||
    fatal "apt-get purge failed"

  sudo apt-get -q autoremove
}

# shellcheck disable=SC2068
apt_install() {
  apt_update

  test -n "$1" && available_versions "$1"

  sudo apt-get -q install $@ ||
    fatal "apt-get install failed"
}

apt_upgrade() {
  apt_update

  sudo apt-get -q upgrade -y ||
    fatal "apt-get upgrade failed"
}

available_versions() {
  case "$1" in
  *=*) ;;
  *)
    versions="$(apt-cache madison "$1" | tr -d ' ' | cut -d '|' -f 1,2 |
      sed 's/|/=/g' | sort | uniq)"

    echo "Please specify a version, available versions are:"
    print_list "$versions"

    clean_exit
    ;;
  esac
}

get_package_version() {
  apt-cache policy "$1" | grep '\*\*' | cut -d ' ' -f 3
}
