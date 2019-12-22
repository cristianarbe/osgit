cleanup() {
  test -f "$OSGIT_PROFILE"/packages.current &&
    rm "$OSGIT_PROFILE"/packages.current
  test -f "$OSGIT_PROFILE"/packages.tmp &&
    rm "$OSGIT_PROFILE"/packages.tmp
  test -f "$OSGIT_PROFILE"/packages.tocheckout &&
    rm "$OSGIT_PROFILE"/packages.tocheckout
}

clean_exit() {
  cleanup
  exit 0
}
