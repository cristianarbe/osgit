#!/bin/sh

set -e

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

original="$(sha256sum "$SCRIPT_DIR"/.local/bin/osgit | head -c 64)"

executable_path="$HOME/.local/bin/osgit"
installed="$(sha256sum "$executable_path" | head -c 64)"

if test "$original" = "$installed"; then
  echo 'Installed correctly.'
else
  echo 'Checksums of your installed file and this version do not match.'
fi
