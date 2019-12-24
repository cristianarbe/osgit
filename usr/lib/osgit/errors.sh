#!/bin/sh
fatal() {
    cleanup
    echo "$@"
    exit 1
}
