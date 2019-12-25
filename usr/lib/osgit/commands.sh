#!/bin/sh

fn_deploy() {
  check_root

  reference="$OSGIT_PROFILE"/packages
  test "$#" -ne 0 && reference="$1"

  changes="$(diff_with_current "$reference")"

  added="$(fn_plus "$changes")"
  removed="$(fn_minus "$changes")"

  ! propose_to_user "$added" "$removed" && clean_exit

  # shellcheck disable=SC2086
  apt_install $added && apt_rm $removed
  cp "$reference" "$OSGIT_PROFILE"/packages
}

fn_clone() {
  test "$#" -eq 0 && clean_exit "Nothing to do."
  check_root
  make_this_master
  fn_deploy "$1"
  add_commit "Clone from $1"
}

fn_add() {
  test "$#" -eq 0 && clean_exit "Nothing to do."

  check_root
  make_this_master

  # shellcheck disable=SC2068
  apt_install $@
  update_packages_and_git "Add $*"
}

fn_rm() {
  test "$#" -eq 0 && clean_exit "Nothing to do."
  check_root
  make_this_master

  apt_rm "$@"
  update_packages_and_git "Remove $*"
}

fn_upgrade() {
  check_root
  make_this_master

  apt_upgrade
  update_packages_and_git "Upgrade packages"
}

fn_checkout() {
  test "$#" -eq 0 && clean_exit "Nothing to do."
  check_root
  generate_checkout_file "$@"

  fn_deploy "$TMP"/packages.tocheckout
  force_checkout "$@"
}

fn_rollback() {
  check_root
  state=

  if test "$#" -ne 0; then
    state="$1"
  else
    state="$(get_menu_result | cut -d ' ' -f 1)"
    display_menu "$(fn_log "")"
  fi

  commit_previous_state "$state"
  fn_deploy "$OSGIT_PROFILE"/packages
}

fn_log() {
  n=10

  test -n "$n" && n="$1"

  git log --oneline | head -n "$n"
}

fn_list() {
  if test ! -f "$OSGIT_PROFILE"/packages; then
    update_packages_and_git "Regenerate cache"
  fi

  cat "$OSGIT_PROFILE"/packages
}

fn_update() {
  check_root
  apt_update

  get_installed >"$OSGIT_PROFILE"/packages
}

fn_show() {
  test "$#" -eq 0 && clean_exit "Nothing to do."
  full_show="$(git show "$1")"

  echo "Added:"
  print_list "$(fn_plus "$full_show")"
  echo "Removed:"
  print_list "$(fn_minus "$full_show")"
}

fn_pin() {
  test "$#" -eq 0 && clean_exit "Nothing to do."
  check_root
  version="$(get_package_version "$1")"
  {
    echo "package: $1"
    echo "Pin: version $version"
    echo "Pin-Priority: 1001"
  } >>/etc/apt/preferences
}

fn_revert() {
  test "$#" -eq 0 && clean_exit "Nothing to do."
  check_root
  git revert --no-commit "$1"
  git commit -m "Revert $1"
  fn_deploy
}

fn_unpin() {
  test "$#" -eq 0 && clean_exit "Nothing to do."
  check_root
  pins="$(grep -n "$1" /etc/apt/preferences | cut -d ':' -f 1)"

  for pin in $pins; do
    end=$((pin + 2))
    sed -i.bak -e "${pin},${end}d" /etc/apt/preferences
  done
}

fn_help() {
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
