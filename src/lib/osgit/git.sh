# Copyright 2019 Cristian Ariza
# Licensed under the EUPL
#
# Git utils

PREFIX="$(cd "$(dirname "$0")"/.. || exit; pwd)"
OSGITPATH="$PREFIX"/var/cache/osgit

git_path(){
  git --git-dir="$OSGITPATH"/.git --work-tree="$OSGITPATH" "$@"
}

