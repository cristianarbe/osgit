/* Copyright 2020 Cristian Ariza */

#include <bsd/string.h>
#include <stdlib.h>

#ifndef COMMANDS_H_
#define COMMANDS_H_

int
deploy(char *path)
{
	int err;
	char cmd[100] = "";

	err = system("apt-get -q update");
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(cmd,
	    "apt-get -q install \"$(comm -13 /home/cariza/.cache/osgit/packages \"",
	    sizeof(cmd));
	(void)strlcat(cmd, path, sizeof(cmd));
	(void)strlcat(cmd, "\"", sizeof(cmd));
	err = system(cmd);
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(cmd,
	    "apt-get -q --autoremove purge \"$(comm -23 /home/cariza/.cache/osgit/packages \"",
	    sizeof(cmd));
	(void)strlcat(cmd, path, sizeof(cmd));
	(void)strlcat(cmd, "\"", sizeof(cmd));
	err = system(cmd);
	if (err != 0) {
		return 1;
	}

	return 0;
}

void
help(char *s)
{
	char *msg =
	    "osgit v1.0.0\n"
	    "Usage: osgit [options] command\n"
	    "\n"
	    "osgit is a command line apt-wrapper and provides commands for\n"
	    "searching and managing as well as version control installed "
	    "packages.\n"
	    "\n"
	    "Commands:\n"
	    "	add/rm - installs/uninstalls packages\n"
	    "	import - sync installed packages with a file\n"
	    "	du - summarise disk usage of installed packages\n"
	    "	help - shows this\n"
	    "	init - initialises the repository\n"
	    "	list - lists installed packages\n"
	    "	log - shows osgit commit log\n"
	    "	pin/unpin - pins/unpins the currently installed version of a "
	    "		package\n"
	    "	revert - reverts a specific commit\n"
	    "	rollback - change the installed packages to a specific commit\n"
	    "	show - prints information about a specific commit\n"
	    "	update - updates cache\n"
	    "	upgrade - upgrade the system by installing/upgrading packages\n"
	    "	versions - show versions of a package available in the "
	    "		repositories\n";
	(void)strlcpy(s, msg, sizeof(s));
}

#endif /* COMMANDS_H_ */
