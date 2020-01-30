/* Copyright 2019 Cristian Ariza
 *
 * See LICENSE file for license details.
 */

#include <dirent.h>
#include <errno.h>

#include "vpkadd.h"

void printusg(void);
void die(string msg);

int
main(int argc, string argv[])
{
	DIR *dir;
	int size;
	string gitdir, tmp;

	// Checking if needs to initialize
	tmp = "%s/.git";
	size = (strlen(tmp) - 2) + strlen(vpkpath) + 1;
	gitdir = malloc(size);
	sprintf(gitdir, "%s/.git", vpkpath);

	dir = opendir(gitdir);
	if (dir == NULL) {
		init();
	}

	free(gitdir);

	// Updates
	(void)update();

	if (argc < 2) {
		close();
	}

	if (strcmp(argv[1], "-c") == 0) {
		(void)checkout("abcde");
	} else if (strcmp(argv[1], "-u") == 0) {
		(void)upgrade();
	} else if (argv[1][0] == '-') {
		printf("vpkadd: Unknown option %s%s\n", argv[0], argv[1]);
		printusg();
		exit(EXIT_FAILURE);
	} else {
		string pkgv[argc - 1];

		for (int i = 0; i < argc - 1; i++) {
			pkgv[i] = argv[i + 1];
		}
		(void)install(pkgv, argc - 1);
	}

	(void)commit();
	(void)close();
}

void
printusg()
{
	printf("Usage: vpkadd [-cu] package-name ...\n");
}

void
die(string diemsg)
{
	fprintf(stderr, "E: %s\n", diemsg);
	exit(EXIT_FAILURE);
}