#!/bin/env sh

update_package_file() {
  dpkg-query -Wf '${Package}\n' >"$OSGIT_PROFILE"/packages
}

fn_dryrun() {
  added="$(fn_plus "$1" | sed 's/\n/ /g; s/^+//g')"
  removed="$(fn_minus "$1" | sed 's/\n/ /g; s/^-//g')"

  if test -n "$added"; then
    echo "The following packages will be installed:"
    for package in $added; do
    printf "\\t%s\\n" "$package"
    done
  else
    echo "No packages will be installed."
  fi

  echo ""

  if test -n "$removed"; then
    echo "The following packages will be to be REMOVED:"
    printf "\\t%s\\n" "$removed"
  else
    echo "No packages will be removed."
  fi

}

fn_pull() {
  cp "$1" "$OSGIT_PROFILE"/packages.new
  dif="$(! diff -u "$OSGIT_PROFILE/packages" "$OSGIT_PROFILE"/packages.new)"
  fn_dryrun "$dif"

  printf "Do you want to continue? [y/N] "
  read -r response

  case "$response" in
  y | Y | yes)
    :
    ;;
  *)
    exit
    ;;
  esac

  sudo apt install "$added"
  sudo apt purge "$removed"
  sudo apt install "$added"
  update_package_file
  rm "$OSGIT_PROFILE"/packages.new
  git commit -m "Pull from $1"
}

fn_add() {
  sudo apt update
  if ! sudo apt install "$@"; then
    exit 1
  fi
  update_package_file
  git add "$OSGIT_PROFILE"/packages -f
  git commit -m "Add $*"
}

fn_rm() {
  if ! sudo apt purge "$@"; then
    exit 1
  fi
  sudo apt autoremove
  update_package_file
  git add "$OSGIT_PROFILE"/packages -f
  git commit -m "Remove $*"
}

fn_upgrade() {
  sudo apt update
  if ! sudo apt upgrade; then
    exit 1
  fi
  update_package_file
  git add "$OSGIT_PROFILE"/packages -f
  git commit -m "Upgrade all packages"
}

fn_checkout() {
  if ! git checkout master; then
    git checkout -- .
    git checkout master 2> /dev/null
  fi

  git checkout "$@" 2> /dev/null

  cp "$OSGIT_PROFILE"/packages "$OSGIT_PROFILE"/packages.tmp
  git checkout master >/dev/null 2>&1
  fn_pull "$OSGIT_PROFILE"/packages.tmp
  git checkout "$@"
}
