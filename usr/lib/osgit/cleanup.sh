#!/bin/sh

cleanup() {
  test -n "$TMP" && test -d "$TMP" && rm -rf "$TMP"
}

clean_exit() {
  cleanup
  exit 0
}
