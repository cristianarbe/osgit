#!/bin/sh

aptc="$(apt list --installed | wc -l)"
vpkc="$(./vpk list | wc -l)"

if test "$aptc" -ne "$vpkc"; then
	exit 1
fi

exit 0
