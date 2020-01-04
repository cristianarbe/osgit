#!/bin/sh
log_fatal() {
  if test "$#" -ne 0; then
    echo "FATAL: $*" >&2
  fi
  exit 1
}

log_error() {
  if test "$#" -ne 0; then
    echo "ERROR: $*" >&2
  fi
}
