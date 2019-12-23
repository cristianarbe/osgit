add_commit() {
  git add "$OSGIT_PROFILE"/packages -f
  git commit -m "$1"
}

force_checkout() {
  git checkout -- .
  git checkout master
  git checkout "$@"
}

make_this_master() {
  this="$(git branch | grep -F '*' | sed 's/* //g')"

  case $this in
  master) ;;
  *)
    # keep the content of this branch, but record a merge
    git merge --strategy=ours master
    git checkout master
    # fast-forward master up to the merge
    git merge "$this"
    ;;
  esac
}

remove_last_commit() { git reset --hard HEAD^; }

generate_checkout_file() {
  force_checkout "$@"
  cp "$OSGIT_PROFILE"/packages "$OSGIT_PROFILE"/packages.tocheckout
  force_checkout master
}

commit_previous_state() {
  git checkout -f "$1" -- .
  add_commit "Rollback to $1"
}
