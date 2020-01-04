#!/bin/sh
os_check_root() {
  if test "$(id -u)" -ne 0; then
    echo "This option must be run as root"
    exit 1
  fi
}
