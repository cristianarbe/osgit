# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Logging

log_fatal() {
  test "$#" -ne 0 && echo "FATAL: $*" >&2
  exit 1
}

