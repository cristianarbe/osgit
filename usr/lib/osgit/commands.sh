<<<<<<< HEAD
# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Main commands that can be called by osgit

PREFIX="$(cd "$(dirname "$0")" || exit; pwd)"/../..
OSGITPATH="$PREFIX"/var/cache/osgit

# shellcheck source=../lib/osgit/apt.sh
. "$PREFIX"/lib/osgit/apt.sh
# shellcheck source=../lib/osgit/log.sh
. "$PREFIX"/lib/osgit/log.sh
# shellcheck source=../lib/osgit/packages.sh
. "$PREFIX"/lib/osgit/packages.sh
# shellcheck source=../lib/osgit/git.sh
. "$PREFIX"/lib/osgit/git.sh

__propose_to_user() {
  test "$#" -ne 2 && log_fatal "incorrect number of arguments"

  if ! apt_show_packages "installed" "$1" && ! apt_show_packages "REMOVED" "$2"; then
    echo "Nothing to do." && return
  fi

  printf "Do you want to continue? [y/N] " && read -r response

  case "$response" in
    y | Y | yes | YES) return 0 ;;
    *) return 1 ;;
  esac
}

__deploy(){
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"
=======
#!/bin/sh

commands_deploy() {
  os_check_root

  reference="$OSGIT_PROFILE"/packages
  test "$#" -ne 0 && reference="$1"

  added="$(comm -12 "$OSGIT_PROFILE"/packages "$reference")"
  removed="$(comm -23 "$OSGIT_PROFILE"/packages "$reference")"

  ! propose_to_user "$added" "$removed" && log_fatal "aborted by the user"
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

  added="$(comm -12 "$OSGITPATH"/packages "$1")"
  removed="$(comm -23 "$OSGITPATH"/packages "$1")"
  ! __propose_to_user "$added" "$removed" && log_fatal "aborted by the user"
  # shellcheck disable=SC2086
<<<<<<< HEAD
  apt_install $added
  # shellcheck disable=SC2086
  apt_rm $removed
}

commands_clone() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  packages_open
  __deploy "$1"
  packages_close "Clone from $1"
}

commands_add() {
  test "$#" -lt 1 && log_fatal "incorrect number of arguments"
=======
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
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

  packages_open
  # shellcheck disable=SC2068
  apt_install $@
<<<<<<< HEAD
  packages_close "Add $*"
}

commands_rm() {
  test "$#" -lt 1 && log_fatal "incorrect number of arguments"

  packages_open
  # shellcheck disable=SC2068
  apt_rm $@
  packages_close "Remove $*"
}

commands_upgrade() {
  test "$#" -ne 0 && log_fatal "incorrect number of arguments"
=======
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
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

  packages_open
  apt_upgrade
<<<<<<< HEAD
  packages_close "System upgrade"
}

commands_rollback() {
  test "$#" -ne 1 && log_fatal "arguments not specified"

  packages_open
  git_commit_previous_state "$1"
  __deploy "$OSGITPATH"/packages
  packages_close

}

commands_log() { git log --oneline; }
=======
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
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

commands_list() {
  ! cat "$OSGITPATH"/packages 2> /dev/null &&
    log_fatal "$OSGITPATH/packages not found"
  }

commands_update() {
  packages_open
  apt_update
  packages_close "Update"
}

<<<<<<< HEAD
commands_show() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"
=======
commands_list() {
  test ! -f "$OSGIT_PROFILE"/packages &&
    log_fatal "$OSGIT_PROFILE/packages not found"
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be

  git show "$1"
}

<<<<<<< HEAD
commands_pin() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  __check_root

  version="$(apt-cache policy "$1" | grep '\*\*' | cut -d ' ' -f 3)"

=======
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

>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be
  {
    echo "package: $1"
    echo "Pin: version $pkg_version"
    echo "Pin-Priority: 1001"
  } >>/etc/apt/preferences
}

commands_revert() {
<<<<<<< HEAD
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  packages_open
  git revert --no-commit "$1"
  git commit -m "Revert $1"
  __deploy "$OSGITPATH"/packages
  packages_close "Revert to $1"
}

commands_unpin() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

=======
  test "$#" -eq 0 && log_fatal "arguments not specified"
  check_root

  git revert --no-commit "$1"
  git commit -m "Revert $1"

  commands_deploy
}

commands_unpin() {
  test "$#" -eq 0 && log_fatal "arguments not specified"
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be
  check_root

  pins="$(grep -n "$1" /etc/apt/preferences | cut -d ':' -f 1)"

  for pin in $pins; do
    end="$((pin + 2))"
    sed -i.bak -e "${pin},${end}d" /etc/apt/preferences
  done
}

commands_help() {
<<<<<<< HEAD
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  echo "osgit $1"
=======
  echo "osgit $VERSION"
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be
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
<<<<<<< HEAD
  __check_root

  test ! -d "$OSGITPATH" && mkdir "$OSGITPATH"

  if test ! -d .git; then
    git init && packages_close "First commit"
=======
  test ! -d "$OSGIT_PROFILE" && mkdir "$OSGIT_PROFILE"
  test -z "$TMP" && fatal "TMP is not set"
  test ! -d "$TMP" && mkdir "$TMP" && chmod 777 "$TMP"

  if test ! -d .git; then
    git init
    get_installed >"$OSGIT_PROFILE"/packages
    add_commit "First commit"
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be
  fi
}
