#!/bin/env sh

fatal(){
    cleanup
    echo "$@"
    exit 1
}
