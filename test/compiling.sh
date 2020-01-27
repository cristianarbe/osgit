#!/bin/sh

set -x

make clean || exit 1
make || exit 1