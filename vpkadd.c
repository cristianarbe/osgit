/* Copyright 2019 Cristian Ariza
 *
 * See LICENSE file for license details.
 */

/* TODO(5): Implement asserts if needed */
/* TODO(3): Make a struct for cmd */
/* TODO(5): Sort variable function declarations by size */
/* TODO(0): Actually launch the shell commands */
/* TODO(5): use getops to parse options */

#include <dirent.h>
#include <errno.h>

#include "vpkadd.h"

// static void die(char *msg);
static void printusg(void);
static void printusg(void);

int
main(int argc, char *argv[])
{
	DIR *dir;
	const char *tmp;
	char *gitdir;
	int size;

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
		close();
	}

	if (strcmp(argv[1], "-c") == 0) {
		(void)checkout("abcde");
	} else if (strcmp(argv[1], "-u") == 0) {
		(void)upgrade();
	} else if (argv[1][0] == '-') {
		goto unknown_option;
	} else {
		char *pkgv[argc - 1];

		for (int i = 0; i < argc - 1; i++) {
			pkgv[i] = argv[i + 1];
		}
		(void)install(pkgv, argc - 1);
	}

	(void)commit();
	(void)close();

	unknown_option:
		printf("vpkadd: Unknown option %s%s\n", argv[0], argv[1]);
		printusg();
		exit(EXIT_FAILURE);

}

void
printusg(void)
{
	printf("Usage: vpkadd [-cu] package-name ...\n");
}

// void
// die(char *diemsg)
// {
// 	fprintf(stderr, "vpkadd: %s\n", diemsg);
// 	exit(EXIT_FAILURE);
// }