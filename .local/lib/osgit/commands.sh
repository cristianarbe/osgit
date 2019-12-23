#!/bin/sh

fn_deploy() {
  reference="$1"

  test -z "$reference" && reference="$OSGIT_PROFILE"/packages

  changes="$(diff_with_current "$reference")"

  added="$(fn_plus "$changes")"
  removed="$(fn_minus "$changes")"

  ! propose_to_user "$added" "$removed" && clean_exit

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
  test -z "$1" && n=10 || n="$1"

  git log --oneline | head -n "$n"
}

fn_list() {
  if test ! -f "$OSGIT_PROFILE"/packages; then
    update_packages_and_git "Regenerate cache"
  fi

  cat "$OSGIT_PROFILE"/packages
}

fn_update() {
  apt_update

  get_installed >"$OSGIT_PROFILE"/packages
}

fn_show() {
  full_show="$(git show "$1")"

  echo "Added:"
  print_list "$(fn_plus "$full_show")"
  echo
  echo "Removed:"
  print_list "$(fn_minus "$full_show")"
}

fn_pin() {
  version="$(get_package_version "$1")"
  echo "package: $1" | sudo tee -a /etc/apt/preferences
  echo "Pin: version $version" | sudo tee -a /etc/apt/preferences
  echo "Pin-Priority: 1001" | sudo tee -a /etc/apt/preferences
}

fn_unpin() {
  grep -n "$1" /etc/apt/preferences | cut -d ':' -f 1
}

fn_revert() {
  git revert "$1"
  fn_deploy
}

fn_unpin() {
  pins="$(grep -n "$1" /etc/apt/preferences | cut -d ':' -f 1)"

  for pin in $pins; do
    end=$((pin + 2))

    sudo sed -i.bak -e "${pin},${end}d" /etc/apt/preferences
  done
}
