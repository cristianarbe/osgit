cleanup() {
    rm "$OSGIT_PROFILE"/packages.current
}

clean_exit() {
    cleanup
    echo "All done!"
    exit 0
}
