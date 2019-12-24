#!/bin/sh

fn_plus() {
    echo "$1" | grep -E "^\\+" | grep -v '++' | sed 's/\n/ /g; s/^+//g'
}

fn_minus() {
    echo "$1" | grep -E "^\\-" | grep -v '\-\-' | sed 's/\n/ /g; s/^-//g'
}

diff_with_current(){ ! diff -u "$TMP"/packages.current "$1"; }
