#!/bin/env sh

set -e

OSGIT_PROFILE="$HOME/.osgit"

for import in "$SHPATH"/src/github.com/cristianarbe/osgit/pkg/*.sh; do
  # shellcheck disable=SC1090
  . "$import"
done

startup() {
  test ! -d "$OSGIT_PROFILE" && mkdir "$OSGIT_PROFILE"

  cd "$OSGIT_PROFILE" ||
    fatal "Could not get into $OSGIT_PROFILE"

  test ! -d .git && git init

  get_installed >"$OSGIT_PROFILE"/packages.current
}

main() {
  startup

  case "$1" in
  "") fatal "Option is missing." ;;
  add | rm | pull | clone | upgrade | rollback | deploy | log | list)
    # shellcheck disable=SC2086
    fn_$*
    ;;
  *) fatal "Option not recognized." ;;
  esac

  clean_exit
}

main "$@"
