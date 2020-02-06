/* Copyright 2019 Cristian Ariza
 *
 * See LICENSE file for license details.
 */

/* Headers */

#include <bsd/string.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>

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

int checkout(char *);
int close(void);
int commit(void);
int init(void);
int install(char *[], int);
int update(void);
int upgrade(void);
static void setmsg(char *, char *);

/* Globals */

char *cmd = "";
char *msg;
const char *_PATH_VPK = "/var/cache/vpk";
static const int icmdc = 0;
static int cmdc = icmdc;

/* Function definitions */

static int
intlen(int x)
{
	if (x >= 1000)
		return 4;
	if (x >= 100)
		return 3;
	if (x >= 10)
		return 2;
	return 1;
}

int
init(void)
{
	DIR *dir;
	char *tmp;
	const char *presub;
	int newc;

	dir = opendir(_PATH_VPK);
	if (dir == NULL) {
		if (mkdir(_PATH_VPK, 0755) != 0) {
			return 1;
		}
	}

	closedir(dir);

	presub = "%sgit --git-dir=%s/.git --work-tree=%s init || exit %i\n";
	newc = strlen(presub) + 2 * (strlen(_PATH_VPK) - 2) +
	    (intlen(VPK_GITINIT_FAILURE) - 2);
	cmdc += newc;

	if (cmdc - newc == icmdc) {
		tmp = (char *)malloc(cmdc + 1);
	} else {
		tmp = (char *)realloc(cmd, cmdc + 1);
	}

	(void)sprintf(
	    tmp, cmd, presub, _PATH_VPK, _PATH_VPK, VPK_GITINIT_FAILURE);

	cmd = tmp;

	return 0;
}

int
update(void)
{
	char *tmp;
	const char *presub;
	int newc;

	/* TODO(5): Implement error codes here */
	presub =
	    "%sdpkg-query -Wf '${Package}=${Version}\\n' | sort > %s/packages || return %i\n"
	    "git --git-dir=%s/.git --work-tree=%s commit -a -m \"Sync\"\n"
	    "apt-get -q update || exit %i\n";

	newc = strlen(presub) + 3 * (strlen(_PATH_VPK) - 2) +
	    (intlen(VPK_PKGDUMP_FAILURE) - 2) +
	    (intlen(VPK_PKGUPDATE_FAILURE) - 2);

	cmdc += newc;

	if (cmdc - newc == icmdc) {
		tmp = (char *)malloc(cmdc + 1);
	} else {
		tmp = (char *)realloc(cmd, cmdc + 1);
	}
	sprintf(tmp, presub, cmd, _PATH_VPK, VPK_PKGDUMP_FAILURE, _PATH_VPK,
	    _PATH_VPK, VPK_PKGUPDATE_FAILURE);

	cmd = tmp;

	return 0;
}

int
checkout(char *id)
{
	char *tmp;
	const char *presub;
	int newc;

	/* TODO(5): Implement error codes here */
	presub =
	    "%sgit --git-dir=%s/.git --work-tree=%s show %s:packages > %s/packages.tmp || exit 6\n"
	    "eval \"apt-get -q install $(comm -13 %s/packages %s/packages.tmp)\" || exit 3\n"
	    "eval \"apt-get -q --autoremove purge $(comm -23 %s/packages %s/packages.tmp)\" || exit 7\n"
	    "rm %s/packages.tmp\n";

	newc = strlen(presub) + 8 * (strlen(_PATH_VPK) - 2) + (strlen(id) - 2);

	cmdc += newc;

	if (cmdc - newc == icmdc) {
		tmp = (char *)malloc(cmdc + 1);
	} else {
		tmp = (char *)realloc(cmd, cmdc + 1);
	}

	if (tmp == NULL) {
		fprintf(stderr, "vpkadd: malloc failed\n");
		return 1;
	}

	(void)sprintf(tmp, presub, cmd, _PATH_VPK, _PATH_VPK, id, _PATH_VPK,
	    _PATH_VPK, _PATH_VPK, _PATH_VPK, _PATH_VPK, _PATH_VPK);

	cmd = tmp;

	setmsg("Checkout ", id);

	return 0;
}

int
upgrade(void)
{
	char *tmp;
	const char *presub;
	int newc;

	/* TODO(5): Implement error codes here */
	presub = "%sapt-get -q upgrade || exit 8\n";

	newc = strlen(presub);

	cmdc += newc;

	if (cmdc - newc == icmdc) {
		tmp = (char *)malloc(cmdc + 1);
	} else {
		tmp = (char *)realloc(cmd, cmdc + 1);
	}
	sprintf(tmp, presub, cmd);

	cmd = tmp;

	setmsg("Upgrade ", "");

	return 0;
}

int
install(char *pkgv[], int pkgc)
{
	int newc, size, pkgstrc;
	const char *presub;
	char *pkgstr, *tmp;

	// -1 here is to always avoid counting the last '\0'
	size = -1;
	for (int i = 0; i < pkgc; i++) {
		size += strlen(pkgv[i]);
	}

	pkgstrc = pkgc + size;

	pkgstr = (char *)malloc(pkgstrc + 1);
	pkgstr[0] = '\0';
	for (int i = 0; i < pkgc; i++) {
		(void)strlcat(pkgstr, pkgv[i], pkgstrc + 1);
		if (i != pkgc - 1) {
			(void)strlcat(pkgstr, " ", pkgstrc + 1);
		}
	}

	pkgstr[pkgstrc] = '\0';

	/* TODO(5): Implement error codes here */
	presub =
	    "%sapt-get -q update || exit 2\napt-get -q install %s || exit 3\n";

	newc = strlen(presub) + (pkgstrc - 2);
	cmdc += newc;

	tmp = (char *)malloc(cmdc + 1);
	if (cmdc - size == icmdc) {
		tmp = (char *)malloc(cmdc + 1);
	} else {
		tmp = (char *)realloc(cmd, cmdc + 1);
	}
	sprintf(tmp, presub, cmd, pkgstr);
	cmd = tmp;

	setmsg("Add ", pkgstr);
	free(pkgstr);

	return 0;
}

int
commit(void)
{
	int size;
	const char *presub;
	char *postsub, *tmp;

	/* TODO(5): Implement error codes here */
	presub =
	    "dpkg-query -Wf '${Package}=${Version}\\n' | sort > %s/packages || exit 10\n"
	    "git --git-dir=%s/.git --work-tree=%s add packages  -f || exit 9\n"
	    "git --git-dir=%s/.git --work-tree=%s commit -a -m \"%s\" || exit 9\n";

	size = strlen(presub) + 5 * (strlen(_PATH_VPK) - 2) + (strlen(msg) - 2);

	postsub = (char *)malloc(size + 1);
	(void)sprintf(postsub, presub, _PATH_VPK, _PATH_VPK, _PATH_VPK,
	    _PATH_VPK, _PATH_VPK, msg);

	cmdc += size;
	if (cmdc - size == icmdc) {
		tmp = (char *)malloc(cmdc + 1);
	} else {
		tmp = (char *)realloc(cmd, cmdc + 1);
	}
	cmd = tmp;
	(void)strlcat(cmd, postsub, cmdc + 1);
	free(postsub);

	return 0;
}

static void
setmsg(char *prefix, char *suffix)
{
	int size;

	size = strlen(prefix) + strlen(suffix);
	msg = malloc(size + 1);
	(void)strlcpy(msg, prefix, size + 1);
	(void)strlcat(msg, suffix, size + 1);
}
