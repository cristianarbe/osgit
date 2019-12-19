#!/bin/env sh

fn_plus() {
    echo "$1" | grep -E "^\\+" | grep -v '++'
}

fn_minus() {
    echo "$1" | grep -E "^\\-" | grep -v '\-\-'
}
