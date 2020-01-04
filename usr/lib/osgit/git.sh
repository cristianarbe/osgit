# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Shorts for git commands

<<<<<<< HEAD
PREFIX="$(cd "$(dirname "$0")" || exit; pwd)"/../..
OSGITPATH="$PREFIX"/var/cache/osgit

git_add_commit() {
  git add "$OSGITPATH"/packages -f
  git commit -m "$1"
=======
git_add_commit() {
  git add "$OSGIT_PROFILE"/packages -f
  git commit -m "$1"
}

git_force_checkout() {
  git checkout -- .
  git checkout master
  git checkout "$@"
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be
}

git_make_this_master() {
  this="$(git branch | grep -F '*' | sed 's/* //g')"

<<<<<<< HEAD
  test "$this" == "master" && return

  # keep the content of this branch, but record a merge
  git merge --strategy=ours master
  git checkout master
  # fast-forward master up to the merge
  git merge "$this"
=======
  if "$this" != "master"; then
    # keep the content of this branch, but record a merge
    git merge --strategy=ours master
    git checkout master
    # fast-forward master up to the merge
    git merge "$this"
  fi
}

git_remove_last_commit() { git reset --hard HEAD^; }

git_generate_checkout_file() {
  git_force_checkout "$@"
  cp "$OSGIT_PROFILE"/packages "$TMP"/packages.tocheckout
  git_force_checkout master
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be
}

git_commit_previous_state() {
  git checkout -f "$1" -- .
  git_add_commit "Rollback to $1"
}
