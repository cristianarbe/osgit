#!/bin/env sh

fn_deploy() {
  if test -n "$1"; then
    reference="$1"
  else
    reference="$OSGIT_PROFILE"/packages
  fi
  dif="$(! diff -u "$OSGIT_PROFILE"/packages.current "$reference")"

  fn_dryrun "$dif"
  printf "Do you want to continue? [y/N] "
  read -r response

  case "$response" in
  y | Y | yes) ;;
  *) exit ;;
  esac

  added="$(fn_plus "$1")"
  removed="$(fn_minus "$1")"

  sudo apt-get update
  # shellcheck disable=SC2086
  sudo apt-get install $added
  # shellcheck disable=SC2086
  sudo apt-get purge $removed
  # shellcheck disable=SC2086
  sudo apt-get install $added
  sudo apt-get autoremove

}

fn_clone() {
  make_this_master
  fn_deploy "$1"
  cp "$1" "$OSGIT_PROFILE"/packages
  add_commit "Clone from $1"
}

fn_add() {
  make_this_master
  sudo apt-get update
  if ! sudo apt-get install "$@"; then
    exit 1
  fi
  update_packages_and_git "Add $*"
}

fn_rm() {
  make_this_master
  if ! sudo apt-get purge "$@"; then
    exit 1
  fi
  sudo apt-get autoremove
  update_packages_and_git "Remove $*"
}

fn_upgrade() {
  make_this_master
  sudo apt-get update
  if ! sudo apt-get upgrade; then
    exit 1
  fi
  update_packages_and_git "Upgrade all packages"
}

fn_checkout() {
  generate_checkout_file "$@"

  fn_deploy "$OSGIT_PROFILE"/packages.tocheckout
  force_checkout "$@"
}

fn_rollback() {
  state="$1"

  if test -z "$state"; then
    state="HEAD~1"
  fi

  commit_previous_state "$state"
  fn_deploy "$OSGIT_PROFILE"/packages
}
