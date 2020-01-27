#!/bin/sh

set -x

./vpk 2>&1 | grep Commands || exit 1