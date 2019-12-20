#!/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

mkdir -p ~/sh/src/github.com/cristianarbe/osgit

cp "$DIR"/cmd ~/sh/src/github.com/cristianarbe/osgit
cp "$DIR"/pkg ~/sh/src/github.com/cristianarbe/osgit

ln -s ~/sh/src/github.com/cristianarbe/osgit/cmd/osgit.sh \
    ~/.local/bin/osgit
