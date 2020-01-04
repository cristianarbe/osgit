<<<<<<< HEAD
# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Logging

log_fatal() {
  test "$#" -ne 0 && echo "FATAL: $*" >&2
  exit 1
}

=======
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
>>>>>>> 0dd2f41bb05e0c530164e5f20857bfd3068bf5be
