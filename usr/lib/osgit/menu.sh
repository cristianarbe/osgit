#!/bin/sh

menu_display() {
  options="$1"
  commit="$TMP/commit"

  i=1
  echo "$options" | while
    read -r line
  do
    # take action on $line #
    echo "$i) $line"
    i=$((i + 1))
  done

  printf "#? "
  read -r response

  i=1
  echo "$options" | while
    read -r line
  do
    if test "$response" -eq "$i"; then
      echo "$line" >"$commit"
      break
    fi
    i=$((i + 1))
  done
}

menu_get() {
  cat "$TMP"/commit
}
