#!/bin/sh

commands_deploy() {
  os_check_root

  reference="$OSGIT_PROFILE"/packages
  test "$#" -ne 0 && reference="$1"

  added="$(comm -12 "$OSGIT_PROFILE"/packages "$reference")"
  removed="$(comm -23 "$OSGIT_PROFILE"/packages "$reference")"

  ! propose_to_user "$added" "$removed" && log_fatal "aborted by the user"

  # shellcheck disable=SC2086
  apt_install $added && apt_rm $removed
  packages_update
}

commands_clone() {
  test "$#" -eq 0 && log_fatal "file not specified"

  os_check_root
  git_make_this_master

  cp "$1" "$OSGIT_PROFILE"/packages
  commands_deploy "$1"
  git_add_commit "Clone from $1"
}

commands_add() {
  test "$#" -eq 0 && log_fatal "arguments not specified"

  os_check_root
  git_make_this_master

  # shellcheck disable=SC2068
  apt_install $@
  packages_update
  git_add_commit "Add $*"
}

commands_rm() {
  test "$#" -eq 0 && log_fatal "arguments not specified"

  os_check_root
  git_make_this_master

  # shellcheck disable=SC2068
  apt_rm "$@"
  packages_update
  git_add_commit "Remove $*"
}

commands_upgrade() {
  check_root
  make_this_master

  apt_upgrade
  packages_update
  git_add_commit "System upgrade"
}

commands_checkout() {
  test "$#" -eq 0 && log_fatal "arguments not specified"

  check_root
  git_generate_checkout_file "$@"

  commands_deploy "$TMP"/packages.tocheckout
  git_force_checkout "$@"
}

commands_rollback() {
  test "$#" -eq 0 && log_fatal "arguments not specified"

  check_root
  state="$1"

  git_commit_previous_state "$state"
  command_deploy "$OSGIT_PROFILE"/packages
}

commands_log() {
  n=10

  test "$#" -ne 0 && n="$1"

  git log --oneline | head -n "$n"
}

commands_list() {
  test ! -f "$OSGIT_PROFILE"/packages &&
    log_fatal "$OSGIT_PROFILE/packages not found"

  cat "$OSGIT_PROFILE"/packages
}

commands_update() {
  check_root
  apt_update

  packages_update
}

commands_show() {
  test "$#" -eq 0 && log_fatal "arguments not specified"

  git show "$1"
}

commands_pin() {
  test "$#" -eq 0 && log_fatal "arguments not specified"

  check_root

  pkg_version="$(get_package_version "$1")"

  {
    echo "package: $1"
    echo "Pin: version $pkg_version"
    echo "Pin-Priority: 1001"
  } >>/etc/apt/preferences
}

commands_revert() {
  test "$#" -eq 0 && log_fatal "arguments not specified"
  check_root

  git revert --no-commit "$1"
  git commit -m "Revert $1"

  commands_deploy
}

commands_unpin() {
  test "$#" -eq 0 && log_fatal "arguments not specified"
  check_root

  pins="$(grep -n "$1" /etc/apt/preferences | cut -d ':' -f 1)"

  for pin in $pins; do
    end=$((pin + 2))
    sed -i.bak -e "${pin},${end}d" /etc/apt/preferences
  done
}

commands_help() {
  echo "osgit $VERSION"
  echo "Usage: osgit [options] command"
  echo ""
  echo "osgit is a commandline apt-wrapper and provides commands for"
  echo "searching and managing as well as version control installed packages."
  echo ""
  echo "Commands:"
  echo "  add - install packages"
  echo "  deploy - sync installed packages with a file"
  echo "  help - shows this"
  echo "  list - lists installed packages"
  echo "  pin - pins the currently installed version of a package"
  echo "  pin - unpins a package"
  echo "  revert - reverts a specific commit"
  echo "  rm - uninstall packages"
  echo "  rollback - change the installed packages to a specific commit"
  echo "  show - prints information about a specific commit"
  echo "  shows osgit commit log"
  echo "  update - updates cache"
  echo "  upgrade - upgrade the system by installing/upgrading packages"
}

commands_init(){
  test ! -d "$OSGIT_PROFILE" && mkdir "$OSGIT_PROFILE"
  test -z "$TMP" && fatal "TMP is not set"
  test ! -d "$TMP" && mkdir "$TMP" && chmod 777 "$TMP"

  if test ! -d .git; then
    git init
    get_installed >"$OSGIT_PROFILE"/packages
    add_commit "First commit"
  fi
}
