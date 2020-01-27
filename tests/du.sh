#!/bin/sh

./vpk du | tail -n 1 | grep linux || exit 1

exit 0