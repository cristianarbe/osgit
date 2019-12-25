#!/bin/sh

cleanup() {
  test -z "$TMP" && fatal "TMP is not set"

  if test -d "$TMP"; then
    rm -f "$TMP"/*

    if ! touch "$TMP"/test 2>/dev/null; then
      echo "FATAL: no write access to tmp folder. Bad previous cleanup?" >&2
      exit 1
    fi
  fi

}

clean_exit() {
  cleanup
  if test "$#" -ne 0; then
    echo "$1"
  fi
  exit 0
}
