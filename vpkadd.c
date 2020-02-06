/* Copyright 2019 Cristian Ariza
 *
 * See LICENSE file for license details.
 */

#include "vpkadd.h"

#include <dirent.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/wait.h>

static char *rtverr(int);
static void die(char *msg);
static void printusg(void);
static void printusg(void);

int
main(int argc, char *argv[])
{
	DIR *dir;
	char *gitdir;
	const char *tmp;
	int size, err;

	// Checking if needs to initialize
	tmp = "%s/.git";
	size = (strlen(tmp) - 2) + strlen(_PATH_VPK) + 1;
	gitdir = malloc(size);
	sprintf(gitdir, "%s/.git", _PATH_VPK);

	dir = opendir(gitdir);
	if (dir == NULL) {
		init();
	}

	free(gitdir);

	// Updates
	(void)update();

	if (argc < 2) {
		goto close;
	}

	if (strcmp(argv[1], "-c") == 0) {
		(void)checkout(argv[2]);
	} else if (strcmp(argv[1], "-u") == 0) {
		(void)upgrade();
	} else if (argv[1][0] == '-') {
		goto unknown_option;
	} else {
		int pkgc = argc - 1;
		char *pkgv[pkgc];

		for (int i = 0; i < argc - 1; i++) {
			pkgv[i] = argv[i + 1];
		}
		(void)install(pkgv, pkgc);
	}

	(void)commit();
	goto close;

	return 0;

unknown_option:
	printf("vpkadd: Unknown option %s %s\n", argv[0], argv[1]);
	printusg();
	exit(EXIT_FAILURE);

close:
	err = WEXITSTATUS(system(cmd));
	if (err != 0) {
		die(rtverr(err));
	}

	printf("All done!\n");

	exit(EXIT_SUCCESS);
}

void
printusg(void)
{
	printf("Usage: vpkadd [-cu] package-name ...\n");
}

void
die(char *diemsg)
{
	fprintf(stderr, "vpkadd: %s\n", diemsg);
	exit(EXIT_FAILURE);
}

static char *
rtverr(int id)
{
	switch (id) {
	case 2:
		return "apt update failed";
	case 3:
		return "apt install failed";
	case 4:
		return "git init failed";
	case 5:
		return "updating packages failed";
	case 6:
		return "git show failed";
	case 7:
		return "apt purge failed";
	case 8:
		return "apt purge failed";
	case 9:
		return "git commit failed";
	case 10:
		return "dumping packages failed";
	default:
		return "failed due to an unknow reason";
	}
}