#!/bin/sh

print_list() {
  for package in $1; do
    printf "\\t%s\\n" "$package"
  done
}
