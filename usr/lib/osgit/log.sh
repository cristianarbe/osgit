# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Logging

log_fatal() {
  echo "E: $*" >&2
  exit 1
}

