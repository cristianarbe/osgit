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

  added="$(comm -12 "$OSGITPATH"/packages "$1")"
  removed="$(comm -23 "$OSGITPATH"/packages "$1")"
  ! __propose_to_user "$added" "$removed" && log_fatal "aborted by the user"
  # shellcheck disable=SC2086
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

  packages_open
  # shellcheck disable=SC2068
  apt_install $@
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

  packages_open
  apt_upgrade
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

commands_list() {
  ! cat "$OSGITPATH"/packages 2> /dev/null &&
    log_fatal "$OSGITPATH/packages not found"
  }

commands_update() {
  packages_open
  apt_update
  packages_close "Update"
}

commands_show() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  git show "$1"
}

commands_pin() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  __check_root

  version="$(apt-cache policy "$1" | grep '\*\*' | cut -d ' ' -f 3)"

  {
    echo "package: $1"
    echo "Pin: version $version"
    echo "Pin-Priority: 1001"
  } >>/etc/apt/preferences
}

commands_revert() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  packages_open
  git revert --no-commit "$1"
  git commit -m "Revert $1"
  __deploy "$OSGITPATH"/packages
  packages_close "Revert to $1"
}

commands_unpin() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  check_root
  pins="$(grep -n "$1" /etc/apt/preferences | cut -d ':' -f 1)"

  for pin in $pins; do
    end="$((pin + 2))"
    sed -i.bak -e "${pin},${end}d" /etc/apt/preferences
  done
}

commands_help() {
  test "$#" -ne 1 && log_fatal "incorrect number of arguments"

  echo "osgit $1"
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
  __check_root

  test ! -d "$OSGITPATH" && mkdir "$OSGITPATH"

  if test ! -d .git; then
    git init && packages_close "First commit"
  fi
}
