#!/bin/sh

list_print() {
  for package in $1; do
    printf "\\t%s\\n" "$package"
  done
  echo
}
