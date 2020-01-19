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

#endif /* COMMANDS_H_ */
