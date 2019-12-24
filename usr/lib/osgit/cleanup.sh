cleanup() {
  for file in "$TMP"/packages.current \
    "$TMP"/packages.tocheckout; do
    test -f "$file" && rm "$file"
  done
}

clean_exit() {
  cleanup
  exit 0
}
