#!/bin/env sh

set -e

for import in "$SHPATH"/src/github.com/cristianarbe/osgit/pkg/*.sh; do
  # shellcheck disable=SC1090
  . "$import"
done

OSGIT_PROFILE="$HOME/.osgit"

startup() {
  if test ! -d "$OSGIT_PROFILE"; then
    mkdir "$OSGIT_PROFILE"
  fi

  cd "$OSGIT_PROFILE" || exit

  if test ! -d .git; then
    git init
  fi

  echo '*' >.gitignore

  get_installed >"$OSGIT_PROFILE"/packages.current
}

main() {
  startup

  case "$1" in
  "")
    echo "Option is missing."
    ;;
  add | rm | pull | checkout | upgrade | rollback | sync)
    fn_$*
    ;;
  commit)
    git "$@"
    ;;
  log)
    n="$2"

    if test -z "$n"; then
      n=5
    fi

    git log --oneline | head -n "$n"
    ;;
  status)
    echo "Changes staged for commit:"
    git diff --staged -U0 | tail -n +4 | grep -v '@@' | grep -v '+++' |
      sed 's/^+/\tadded: /g; s/^-/\tremoved: /g'
    ;;
  list)
    cat "$OSGIT_PROFILE"/packages
    ;;
  *)
    echo "Option not recognized."
    ;;
  esac

  rm "$OSGIT_PROFILE"/packages.current
}

main "$@"
