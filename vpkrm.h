/* Copyright 2019 Cristian Ariza
 *
 * See LICENSE file for license details.
 */

/* Headers */

#define _GNU_SOURCE

#include <bsd/string.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string.h>

#include "pathnames.h"

/* Macros */

#define VPK_SUCCESS 0
#define VPK_FAILURE 1
#define VPK_APTUPDATE_FAILURE 2
#define VPK_APTINSTALL_FAILURE 3
#define VPK_GITINIT_FAILURE 4
#define VPK_PKGUPDATE_FAILURE 5
#define VPK_SHOW_FAILURE 6
#define VPK_APTPURGE_FAILURE 7
#define VPK_APTUPGRADE_FAILURE 8
#define VPK_GITCOMMIT_FAILURE 9
#define VPK_PKGDUMP_FAILURE 10

/* Types */

/* Function declarations */

int revert(char *);
int close(void);
int commit(void);
int init(void);
int install(char *[], int);
int update(void);
int upgrade(void);
static int setmsg(char *, char *);

/* Globals */

char *cmd = "";
char *msg;

/* Function definitions */

int
init(void)
{
	DIR *dir;
	char *tmp;
	const char *presub;
	int err;

	dir = opendir(_PATH_VPK);
	if (dir == NULL) {
		if (mkdir(_PATH_VPK, 0755) != 0) {
			return 1;
		}
	}

	closedir(dir);

	presub = "%sgit --git-dir=%s/.git --work-tree=%s init || exit %i\n";
	err = asprintf(
	    &tmp, presub, cmd, _PATH_VPK, _PATH_VPK, VPK_GITINIT_FAILURE);
	if (err < 0) {
		return 1;
	}

	cmd = tmp;

	return 0;
}

int
update(void)
{
	char *tmp;
	const char *presub;
	int newc, size, err;

	/* TODO(5): Implement error codes here */
	presub =
	    "%sdpkg-query -Wf '${Package}=${Version}\\n' | sort > %s/packages || return %i\n"
	    "git --git-dir=%s/.git --work-tree=%s add packages -f \n"
	    "git --git-dir=%s/.git --work-tree=%s commit -m \"Sync\"\n";

	err = asprintf(&tmp, presub, cmd, _PATH_VPK, VPK_PKGDUMP_FAILURE,
	    _PATH_VPK, _PATH_VPK);
	if (err < 1) {
		return 1;
	}

	cmd = tmp;

	return 0;
}

int
revert(char *id)
{
	char *tmp;
	const char *presub;
	int newc, err;

	/* TODO(5): Implement error codes here */
	presub =
	    "%scp %s/packages %s/packages/packages.tmp"
	    "git --git-dir %s/.git --work-tree=%s revert --no-commit %s"
	    "apt-get -q install $(comm -13 %s/packages.tmp %s/packages)"
	    "apt-get -q autoremove $(comm -23 %s/packages.tmp %s/packages)";

	err = asprintf(&tmp, presub, cmd, _PATH_VPK, _PATH_VPK, _PATH_VPK,
	    _PATH_VPK, id, _PATH_VPK, _PATH_VPK, _PATH_VPK, _PATH_VPK);
	if (err < 0) {
		return 1;
	}

	cmd = tmp;

	err = setmsg("Revert ", id);
	if (err != 0) {
		return 1;
	}

	return 0;
}

int
upgrade(void)
{
	char *tmp;
	const char *presub;
	int newc, err;

	/* TODO(5): Implement error codes here */
	presub = "%sapt-get -q upgrade || exit 8\n";

	err = asprintf(&tmp, presub, cmd);
	if (err < 0) {
		return 1;
	}

	cmd = tmp;

	setmsg("Upgrade", "");

	return 0;
}

int
uninstall(char *pkgv[], int pkgc)
{
	int newc, strsize, err;
	const char *presub;
	char *pkgstr, *tmp;

	strsize = pkgc - 1;
	for (int i = 0; i < pkgc; i++) {
		strsize += strlen(pkgv[i]);
	}

	pkgstr = malloc(strsize + 1);
	if (pkgstr == NULL) {
		return 1;
	}

	pkgstr[0] = '\0';
	for (int i = 0; i < pkgc; i++) {
		(void)strlcat(pkgstr, pkgv[i], strsize + 1);

		if (i < pkgc - 1) {
			(void)strlcat(pkgstr, " ", strsize + 1);
		}
	}

	/* TODO(5): Implement error codes here */
	presub = "%sapt-get -q purge %s || exit 3\n";

	err = asprintf(&tmp, presub, cmd, pkgstr);
	if (err < 0) {
		return 1;
	}

	cmd = tmp;

	err = setmsg("Remove ", pkgstr);
	if (err != 0) {
		return 1;
	}
	free(pkgstr);

	return 0;
}

int
commit(void)
{
	int size, err;
	const char *presub;
	char *tmp;

	/* TODO(5): Implement error codes here */
	presub =
	    "%sdpkg-query -Wf '${Package}=${Version}\\n' | sort > %s/packages || exit 10\n"
	    "git --git-dir=%s/.git --work-tree=%s add packages  -f || exit 9\n"
	    "git --git-dir=%s/.git --work-tree=%s commit -m \"%s\" || exit 9\n";

	err = asprintf(&tmp, presub, cmd, _PATH_VPK, _PATH_VPK, _PATH_VPK,
	    _PATH_VPK, _PATH_VPK, msg);
	if (err < 0) {
		return 1;
	}

	cmd = tmp;

	return 0;
}

static int
setmsg(char *prefix, char *suffix)
{
	int size;

	size = strlen(prefix) + strlen(suffix);
	msg = malloc(size + 1);
	if (msg == NULL) {
		return 1;
	}

	(void)strlcpy(msg, prefix, size + 1);
	(void)strlcat(msg, suffix, size + 1);

	return 0;
}
