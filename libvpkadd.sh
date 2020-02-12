#!/bin/sh

quiet() {
	"$@" > /dev/null
}

vpkinit() {
	mkdir -p "$1" || return 1

	quiet git --git-dir="$1"/.git --work-tree="$1" init || return 1
}

vpkupdate() {
	dpkg-query -Wf '${Package}=${Version}\\n' | sort > "$1"/packages || return 1
	quiet git --git-dir="$1"/.git --work-tree="$1" add packages -f || return 1
	quiet git --git-dir="$1"/.git --work-tree="$1" commit -m "Sync"
	quiet apt-get update || return 1
}

vpkinstall() { apt-get install "$@"; }

vpkupgrade() { apt-get upgrade -y; }

vpkcommit() {
	dpkg-query -Wf '${Package}=${Version}\\n' | sort > "$1"/packages || return 1
	quiet git --git-dir="$1"/.git --work-tree="$1" add packages -f || return 1
	quiet git --git-dir="$1"/.git --work-tree="$1" commit -m "$2" || return 1
}

vpkcheckout(){
    trap 'rm -f "$1"/packages.tmp' EXIT
	quiet git --git-dir="$1"/.git --work-tree="$1" show "$2":packages > "$1"/packages.tmp
    # shellcheck disable=SC2046
	apt-get install $(comm -13 "$1"/packages "$1"/packages.tmp)
    # shellcheck disable=SC2046
	apt-get --autoremove purge $(comm -23 "$1"/packages "$1"/packages.tmp)
	rm "$1"/packages.tmp
}
