#!/bin/sh

exit_clean() {
  test -z "$TMP" && log_fatal "TMP is not set"

  if test -d "$TMP"; then
    rm -f "$TMP"/*

    if ! touch "$TMP"/test 2>/dev/null; then
      log_fatal "no write access to tmp folder. Bad previous cleanup?" >&2
    fi
  fi

  test "$#" -ne 0 && echo "$1"
  exit 0
}
