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
  for package in $2; do
    printf "\\t%s\\n" "$package"
  done

}

propose_to_user() {
  show_packages "$1" "installed"
  echo ""
  show_packages "$2" "REMOVED"

  printf "Do you want to continue? [y/N] " && read -r response

  case "$response" in
  y | Y | yes | YES) return 0 ;;
  *) return 1 ;;
  esac
}

# shellcheck disable=SC2068
apt_rm() {
  sudo apt-get purge $@ ||
    fatal "apt purge failed"

  sudo apt-get autoremove
}

# shellcheck disable=SC2068
apt_install() {
  sudo apt-get update

  sudo apt-get install $@ ||
    fatal "apt install failed"
}

apt_upgrade() {
  sudo apt-get update

  sudo apt-get upgrade -y ||
    fatal "apt upgrade failed"
}
