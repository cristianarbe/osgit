#!/bin/sh
fatal() {
  cleanup
  echo "FATAL: $*" >&2
  exit 1
}

error() {
  cleanup
  if test "$#" -ne 0; then
    echo "E: $*" >&2
    echo "Run 'osgit help' for usage information"
  fi
  exit 1
}
