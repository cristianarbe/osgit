fatal() {
    cleanup
    echo "$@"
    exit 1
}
