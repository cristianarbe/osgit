# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Main commands that can be called by osgit

PREFIX="$(cd "$(dirname "$0")"/.. || exit; pwd)"
OSGITPATH="$PREFIX"/var/cache/osgit

# shellcheck source=../lib/osgit/apt.sh
. "$PREFIX"/lib/osgit/apt.sh
# shellcheck source=../lib/osgit/git.sh
. "$PREFIX"/lib/osgit/git.sh
# shellcheck source=../lib/osgit/log.sh
. "$PREFIX"/lib/osgit/log.sh
# shellcheck source=../lib/osgit/packages.sh
. "$PREFIX"/lib/osgit/packages.sh

__propose_to_user() {
  if ! apt_show_packages "installed" "$1" && ! apt_show_packages "REMOVED" "$2"; then
    return
  fi

  printf "Do you want to continue? [y/N] "
  read -r response

  case "$response" in
    y | Y | yes | YES) return 0 ;;
    *) return 1 ;;
  esac
}

__deploy(){
  tmp="$(mktemp)"
  apt_get_installed > "$tmp"

  if ! __propose_to_user "$(comm -13 "$tmp" "$1")" "$(comm -23 "$tmp" "$1")"; then
    log_fatal "aborted by the user"
  fi

  # shellcheck disable=SC2086
  apt_install $added
  # shellcheck disable=SC2086
  apt_rm $removed
}

commands_clone() {
  __deploy "$1"
  packages_close "Clone from $1"
}

commands_add() {
  # shellcheck disable=SC2068
  apt_install $@
  packages_close "Add $*"
}

commands_rm() {
  # shellcheck disable=SC2068
  apt_rm $@
  packages_close "Remove $*"
}

commands_upgrade() {
  apt_upgrade
  packages_close "System upgrade"
}

commands_rollback() {
  if test "$#" -ne 1; then
    log_fatal "arguments not specified"
  fi

  tmp="$(mktemp)"
  git show "$1":packages > "$tmp"
  __deploy "$tmp"
  packages_close "Rollback to $1"

}

commands_list() {
  if ! cat "$OSGITPATH"/packages 2> /dev/null; then
    log_fatal "$OSGITPATH/packages not found"
  fi
}

commands_update() {
  apt_update
  packages_close "Update"
}

commands_show() {
  tmp="$(mktemp)"
  tmp_prev="$(mktemp)"

  git show "$1":packages > "$tmp"
  git show "$1"^1:packages > "$tmp_prev"

  echo "* Packages added"
  comm -13 "$tmp_prev" "$tmp"

  echo "* Packages removed"
  comm -23 "$tmp_prev" "$tmp"
}

commands_pin() {
  pkg_version="$(apt-cache policy "$1" | grep '\*\*' | cut -d ' ' -f 3)"

  {
    echo "package: $1"
    echo "Pin: version $pkg_version"
    echo "Pin-Priority: 1001"
  } >>/etc/apt/preferences
}

commands_revert() {
  git revert --no-commit "$1"
  __deploy "$OSGITPATH"/packages
  packages_close "Revert to $1"
}

commands_unpin() {
  pins="$(grep -n "$1" /etc/apt/preferences | cut -d ':' -f 1)"

  for pin in $pins; do
  end="$((pin + 2))"
  sed -i.bak -e "${pin},${end}d" "/etc/apt/preferences"
done
}

commands_help() {
  echo "osgit $1"
  echo "Usage: osgit [options] command"
  echo ""
  echo "osgit is a command line apt-wrapper and provides commands for"
  echo "searching and managing as well as version control installed packages."
  echo ""
  echo "Commands:"
  echo "  add/rm - installs/uninstalls packages"
  echo "  clone - sync installed packages with a file"
  echo "  help - shows this"
  echo "  list - lists installed packages"
  echo "  log - shows osgit commit log"
  echo "  pin/unpin - pins/unpins the currently installed version of a package"
  echo "  revert - reverts a specific commit"
  echo "  rollback - change the installed packages to a specific commit"
  echo "  show - prints information about a specific commit"
  echo "  update - updates cache"
  echo "  upgrade - upgrade the system by installing/upgrading packages"
}

commands_init(){
  if test ! -d "$OSGITPATH"; then
    mkdir -p "$OSGITPATH"
  fi

  cd "$OSGITPATH" || log_fatal  "could not cd"

  if ! touch "$OSGITPATH"/packages; then
    __check_root
  fi

  if test ! -d .git; then
    git init
    packages_close "First commit"
  fi

  echo 'initialised'
}
