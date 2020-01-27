/* Copyright 2020 Cristian Ariza */

#include <bsd/string.h>
#include <stdio.h>
#include <stdlib.h>

#include "./log.h"

#ifndef vpk_H_
#define vpk_H_

int
vpkdep(char *path)
{
	int err;
	char cmd[100] = "";

	err = system("apt-get -q update");
	if (err != 0) {
		logerr("E: apt-get update command failed\n");
		return 1;
	}

	(void)strlcpy(cmd,
	    "apt-get -q install \"$(comm -13 /home/cariza/.cache/vpk/packages \"",
	    sizeof(cmd));
	(void)strlcat(cmd, path, sizeof(cmd));
	(void)strlcat(cmd, "\"", sizeof(cmd));
	err = system(cmd);
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(cmd,
	    "apt-get -q --autoremove purge \"$(comm -23 /home/cariza/.cache/vpk/packages \"",
	    sizeof(cmd));
	(void)strlcat(cmd, path, sizeof(cmd));
	(void)strlcat(cmd, "\"", sizeof(cmd));
	err = system(cmd);
	if (err != 0) {
		return 1;
	}

	return 0;
}

static int
vpkclose(char *msg)
{
	char cmd[200] = "";

	int err = system("dpkg-query -Wf '${Package}=${Version}\n' | sort -n > "
			 "/home/cariza/.cache/vpk/packages");
	if (err != 0) {
		return 1;
	}

	int alldone = system(
	    "git --git-dir=/home/cariza/.cache/vpk/.git --work-tree=/home/cariza/.cache/vpk diff-index --quiet HEAD --");

	if (alldone == 0) {
		return 0;
	}

	err = system("git --git-dir=/home/cariza/.cache/vpk/.git "
		     "--work-tree=/home/cariza/.cache/vpk add packages -f");
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(cmd,
	    "git --git-dir=/home/cariza/.cache/vpk/.git "
	    "--work-tree=/home/cariza/.cache/vpk commit -m \"",
	    sizeof(cmd));
	(void)strlcat(cmd, msg, sizeof(cmd));
	(void)strlcat(cmd, "\"", sizeof(cmd));
	err = system(cmd);
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
vpkadd(char *vpk)
{
	char cmd[100] = "";
	char msg[100] = "";

	int err = system("/usr/bin/apt-get -q update");
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(cmd, "apt-get -q install ", sizeof(cmd));
	(void)strlcat(cmd, vpk, sizeof(cmd));

	err = system(cmd);
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(msg, "Add ", sizeof(msg));
	(void)strlcat(msg, vpk, sizeof(msg));

	err = vpkclose(msg);
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
vpkrm(char *params)
{
	char msg[100] = "";
	char cmd[100] = "";

	(void)strlcpy(cmd, "/usr/bin/apt-get --autoremove purge ", sizeof(cmd));
	(void)strlcat(cmd, params, sizeof(cmd));

	int err = system(cmd);
	if (err != 0) {
		return 1;
	}

	(void)strlcpy(msg, "Remove ", sizeof(msg));
	(void)strlcat(msg, params, sizeof(msg));
	err = vpkclose(msg);
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
vpkdu()
{
	int err =
	    system("dpkg-query -Wf '${Installed-Size} ${Package}\n' | sort -n");
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
vpklist()
{
	FILE *fptr;
	char c;

	// Open file
	fptr = fopen("/home/cariza/.cache/vpk/packages", "r");
	if (fptr == NULL) {
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
vpklog()
{
	int err = system(
	    "git --git-dir=/home/cariza/.cache/vpk/.git --work-tree=/home/cariza/.cache/vpk/ log --oneline");
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
vpkupgrade()
{
	int err = system("/usr/bin/apt-get update");
	if (err != 0) {
		return 1;
	}
	err = system("/usr/bin/apt-get upgrade -y");
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
vpkinit()
{
	int err = system("mkdir -p /home/cariza/.cache/vpk/");
	if (err != 0) {
		return 1;
	}

	err = system("mkdir -p /var/log/vpk/");
	if (err != 0) {
		return 1;
	}

	err = system("git --git-dir=/home/cariza/.cache/vpk/.git "
		     "--work-tree=/home/cariza/.cache/vpk/ init");
	if (err != 0) {
		return 1;
	}

	err = vpkclose("First commit");
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
vpkupdate()
{
	int err = system("/usr/bin/apt-get update");
	if (err != 0) {
		return 1;
	}

	vpkclose("First commit");

	return 0;
}

int
vpkrev(char id[])
{
	printf("%s", id);
	return 0;
}

#endif /* vpk_H_ */
