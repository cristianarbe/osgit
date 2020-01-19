/* Copyright 2020 Cristian Ariza */

#include <bsd/string.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef PKGS_H_
#define PKGS_H_

static int
pkgsclose(char *msg)
{
	char cmd[200] = "";
	int err;

	err = system("dpkg-query -Wf '${Package}=${Version}\n' | sort -n > "
		     "/home/cariza/.cache/osgit/packages");

	if (err != 0) {
		fprintf(stderr, "updating packages");
		return 1;
	}

	err = system("git --git-dir=/home/cariza/.cache/osgit/.git "
		     "--work-tree=/home/cariza/.cache/osgit add packages -f");
	if (err != 0) {
		fprintf(stderr, "adding packages file to stash");
		return 1;
	}

	(void)strlcpy(cmd,
	    "git --git-dir=/home/cariza/.cache/osgit/.git "
	    "--work-tree=/home/cariza/.cache/osgit commit -m \"",
	    sizeof(cmd));
	(void)strlcat(cmd, msg, sizeof(cmd));
	(void)strlcat(cmd, "\" > /dev/null 2>&1", sizeof(cmd));
	err = system(cmd);
	if (err != 0) {
		fprintf(stderr, "comitting failed");
		return 1;
	}

	return 0;
}

int
pkgsadd(char *pkgs)
{
	char cmd[100] = "";
	char msg[100] = "";

	int err = system("/usr/bin/apt -q update");
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(cmd, "apt -q install ", sizeof(cmd));
	(void)strlcat(cmd, pkgs, sizeof(cmd));

	err = system(cmd);
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(msg, "Add", sizeof(msg));
	(void)strlcat(msg, pkgs, sizeof(msg));

	err = pkgsclose(msg);
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
pkgsdu()
{
	int err =
	    system("dpkg-query -Wf '${Installed-Size} ${Package}\n' | sort -n");
	if (err != 0) {
		fprintf(stderr, "E: error getting installed packages\n");
		return 1;
	}

	return 0;
}

int
pkgslist()
{
	char content[2000] = "";

	int err = filecpy(
	    content, "/home/cariza/.cache/osgit/packages", sizeof(content));
	if (err != 0) {
		fprintf(stderr, "E: failed reading file contents");
		return 1;
	}

	printf("%s", content);

	return 0;
}

#endif /* PKGS_H_ */
