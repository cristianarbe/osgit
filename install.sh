#!/bin/sh -e

SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR" || exit
SCRIPT_DIR="$(pwd)"

if test ! -d "$HOME"/.local/bin; then
  mkdir -p "$HOME"/.local/bin
fi

case "$PATH" in
*.local/bin*)
  :
  ;;
*)
  # shellcheck disable=SC2016
  echo 'export PATH="$HOME/.local/bin:$PATH"' >>~/.bashrc
  ;;
esac

cp "$SCRIPT_DIR"/.local "$HOME" -r
