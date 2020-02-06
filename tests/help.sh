#!/bin/sh

set -x

./vpk help 2>&1 | grep Commands || exit 1