#!/bin/sh
fatal() {
    cleanup
    echo "$@" >&2
    exit 1
}
