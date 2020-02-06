#!/bin/sh

set -x

rm -r /home/cariza/.cache/vpk/ || exit 1
./vpk init || exit 1