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

  sudo apt update
  sudo apt install $added
  sudo apt purge $removed
  sudo apt install $added
  sudo apt autoremove

}

fn_clone() {
  make_this_master
  fn_deploy "$1"
  cp "$1" "$OSGIT_PROFILE"/packages
  add_commit "Clone from $1"
}

fn_add() {
  make_this_master
  sudo apt update
  if ! sudo apt install "$@"; then
    exit 1
  fi
  update_packages_and_git "Add $*"
}

fn_rm() {
  make_this_master
  if ! sudo apt purge "$@"; then
    exit 1
  fi
  sudo apt autoremove
  update_packages_and_git "Remove $*"
}

fn_upgrade() {
  make_this_master
  sudo apt update
  if ! sudo apt upgrade; then
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
