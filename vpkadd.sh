set -e
test -z "$VPKPATH" && echo "VPKPATH is not set" && exit 1
apt-get -q update
case "$1" in
	"-u")
		apt-get -q upgrade
		dpkg-query -Wf '${Package}=${Version}\n' | sort >"$VPKPATH"/packages
		git commit -a -m "Upgrade" >/dev/null 2>&1
		;;
	"")
		dpkg-query -Wf '${Package}=${Version}\n' | sort >"$VPKPATH"/packages
		git commit -a -m "Sync" >/dev/null 2>&1
		;;
	*)
		apt-get -q install $*
		dpkg-query -Wf '${Package}=${Version}\n' | sort >"$VPKPATH"/packages
		git commit -a -m "Add $*" >/dev/null 2>&1
		;;
esac
