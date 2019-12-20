#!/bin/env sh

fn_deploy() {
  reference="$1"

  test -z "$reference" && reference="$OSGIT_PROFILE"/packages

  changes="$(diff_with_current "$reference")"

  added="$(fn_plus "$changes")"
  removed="$(fn_minus "$changes")"

  ! propose_to_user "$1" "$2" && clean_exit

  # shellcheck disable=SC2086
  apt_install $added && apt_rm $removed
}

fn_clone() {
  make_this_master
  fn_deploy "$1"
  cp "$1" "$OSGIT_PROFILE"/packages
  add_commit "Clone from $1"
}

fn_add() {
  make_this_master

  # shellcheck disable=SC2068
  apt_install $@
  update_packages_and_git "Add $*"
}

fn_rm() {
  make_this_master

  apt_rm "$@"
  update_packages_and_git "Remove $*"
}

fn_upgrade() {
  make_this_master

  apt_upgrade
  update_packages_and_git "Upgrade packages"
}

fn_checkout() {
  generate_checkout_file "$@"

  fn_deploy "$OSGIT_PROFILE"/packages.tocheckout
  force_checkout "$@"
}

fn_rollback() {
  state="$1"

  test -z "$state" && state="HEAD~1"

  commit_previous_state "$state"
  fn_deploy "$OSGIT_PROFILE"/packages
}

fn_log() {
  test -z "$1" && n=5 || n="$1"

  git log --oneline | head -n "$n"
}

fn_list() { cat "$OSGIT_PROFILE"/packages; }
