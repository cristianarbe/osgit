#!/bin/env sh

fn_plus() {
    echo "$1" | grep -E "^\\+" | grep -v '++' | sed 's/\n/ /g; s/^+//g'
}

fn_minus() {
    echo "$1" | grep -E "^\\-" | grep -v '\-\-' | sed 's/\n/ /g; s/^-//g'
}
