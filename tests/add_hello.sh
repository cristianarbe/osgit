#!/bin/sh

set -x

if ! apt list --installed | grep hello; then
	./vpk add hello || exit 1
	apt list --installed | grep hello || exit 1
	./vpk log | head -n 1 | grep 'Add hello' || exit 1
fi

exit 0
