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

	int err = system("dpkg-query -Wf '${Package}=${Version}\n' | sort -n > "
			 "/home/cariza/.cache/osgit/packages");
	if (err != 0) {
		fprintf(stderr, "E: failed updating packages");
		return 1;
	}

	int alldone = system(
	    "git --git-dir=/home/cariza/.cache/osgit/.git --work-tree=/home/cariza/.cache/osgit diff-index --quiet HEAD --");

	printf("alldone is %i\n", alldone);

	if (alldone == 0) {
		return 0;
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
		fprintf(stderr, "E: comitting failed\n");
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

	(void)strlcpy(msg, "Add ", sizeof(msg));
	(void)strlcat(msg, pkgs, sizeof(msg));

	err = pkgsclose(msg);
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
pkgsrm(char *params)
{
	char msg[100] = "";
	char cmd[100] = "";

	(void)strlcpy(cmd, "/usr/bin/apt --autoremove purge ", sizeof(cmd));
	(void)strlcat(cmd, params, sizeof(cmd));

	printf("Running %s\n", cmd);
	int err = system(cmd);
	if (err != 0) {
		fprintf(stderr, "E: error purging\n");
		return 1;
	}

	(void)strlcpy(msg, "Remove ", sizeof(msg));
	(void)strlcat(msg, params, sizeof(msg));
	err = pkgsclose(msg);
	if (err != 0) {
		fprintf(stderr, "E: error closing pkgs\n");
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
	FILE *fptr;
	char c;

	// Open file
	fptr = fopen("/home/cariza/.cache/osgit/packages", "r");
	if (fptr == NULL) {
		fprintf(stderr, "E: cannot open file \n");
		return 1;
	}

	c = fgetc(fptr);
	while (c != EOF) {
		printf("%c", c);
		c = fgetc(fptr);
	}

	(void)fclose(fptr);
	return 0;
}

int
pkgslog()
{
	int err = system(
	    "git --git-dir=/home/cariza/.cache/osgit/.git --work-tree=/home/cariza/.cache/osgit/ log --oneline");
	if (err != 0) {
		fprintf(stderr, "E: error getting log\n");
		return 1;
	}

	return 0;
}

int
pkgsupgrade()
{
	int err = system("/usr/bin/apt update");
	if (err != 0) {
		fprintf(stderr, "E: error updating\n");
		return 1;
	}
	err = system("/usr/bin/apt upgrade -y");
	if (err != 0) {
		fprintf(stderr, "E: error upgrading\n");
		return 1;
	}

	return 0;
}

#endif /* PKGS_H_ */
