#!/bin/bash
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This option must be run as root"
    exit 1
  fi
}
