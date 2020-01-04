# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Shorts for git commands

PREFIX="$(cd "$(dirname "$0")"/.. || exit; pwd)"
OSGITPATH="$PREFIX"/var/cache/osgit

git_add_commit() {
  git add "$OSGITPATH"/packages -f
  git commit -m "$1"
}

git_make_this_master() {
  this="$(git branch | grep -F '*' | sed 's/* //g')"

  if test "$this" = "master"; then
    return
  fi

  # keep the content of this branch, but record a merge
  git merge --strategy=ours master
  git checkout master
  # fast-forward master up to the merge
  git merge "$this"
}

git_commit_previous_state() {
  git checkout -f "$1" -- .
  git_add_commit "Rollback to $1"
}
