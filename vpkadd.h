/* Copyright 2019 Cristian Ariza
 *
 * See LICENSE file for license details.
 */

/* Headers */

#include <bsd/string.h>
#include <dirent.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>

/* Types */

typedef char *string;

/* Function declarations */

int checkout(string id);
int commit();
int init(void);
int install(string pkgv[], int pkgc);
int update(void);
int upgrade(void);
void close(void);
void setmsg(string prefix, string suffix);

/* Globals */

const bool debug = true;
const int icmdc = 7;
const string vpkpath = "/var/cache/vpk";

int cmdc = icmdc;
string cmd = "set -x\n";
string msg;

/* Function definitions */

int
init(void)
{
	int size;
	string presub, postsub, tmp, setx;
	DIR *dir;

	dir = opendir(vpkpath);
	if (dir == NULL) {
		if (mkdir(vpkpath, 0755) != 0) {
			return 1;
		}
	}

	presub = "git --git-dir=%s/.git --work-tree=%s init || exit 1\n";
	size = strlen(presub) + 2 * (strlen(vpkpath) - 2);

	postsub = (string)malloc(size + 1);
	sprintf(postsub, presub, vpkpath, vpkpath);

	cmdc += size;
	if (cmdc - size == icmdc) {
		tmp = (string)malloc(cmdc + 1);
	} else {
		tmp = (string)realloc(cmd, cmdc + 1);
	}
	cmd = tmp;
	(void)strlcat(cmd, postsub, cmdc + 1);
	free(postsub);

	return 0;
}

int
update(void)
{
	int size;
	string presub, postsub, tmp;

	presub =
	    "dpkg-query -Wf '${Package}=${Version}\\n' | sort > %s/packages || exit 1\n"
	    "git --git-dir=%s/.git --work-tree=%s commit -a -m \"Sync\" > /dev/null 2>&1\n"
	    "apt-get -q update || exit 1\n";

	size = strlen(presub) + 3 * (strlen(vpkpath) - 2);

	postsub = (string)malloc(size + 1);
	sprintf(postsub, presub, vpkpath, vpkpath, vpkpath);

	cmdc += size;
	if (cmdc - size == icmdc) {
		tmp = (string)malloc(cmdc + 1);
	} else {
		tmp = (string)realloc(cmd, cmdc + 1);
	}
	cmd = tmp;
	(void)strlcat(cmd, postsub, cmdc + 1);
	free(postsub);

	return 0;
}

int
checkout(string id)
{
	int size;
	string presub, postsub, tmp;

	presub =
	    "git --git-dir=%s/.git --work-tree=%s show %s:packages > %s/packages.tmp || exit 1\n"
	    "eval \"apt-get -q install $(comm -13 %s/packages %s/packages.tmp)\" || exit 1\n"
	    "eval \"apt-get -q --autoremove purge $(comm -23 %s/packages %s/packages.tmp)\" || exit 1\n";

	size = strlen(presub) + 7 * (strlen(vpkpath) - 2) + (strlen(id) - 2);

	postsub = (string)malloc(size);
	(void)sprintf(postsub, presub, vpkpath, vpkpath, id, vpkpath, vpkpath,
	    vpkpath, vpkpath, vpkpath);

	cmdc += size;
	if (cmdc - size == icmdc) {
		tmp = (string)malloc(cmdc + 1);
	} else {
		tmp = (string)realloc(cmd, cmdc + 1);
	}
	cmd = tmp;
	(void)strlcat(cmd, postsub, cmdc + 1);
	free(postsub);

	setmsg("Checkout ", id);

	return 0;
}

int
upgrade(void)
{
	string presub, postsub, tmp;

	postsub = "apt-get -q upgrade\n";

	cmdc += strlen(postsub);
	if (cmdc - strlen(postsub) == icmdc) {
		tmp = (string)malloc(cmdc + 1);
	} else {
		tmp = (string)realloc(cmd, cmdc + 1);
	}
	cmd = tmp;
	strlcat(cmd, postsub, cmdc + 1);

	setmsg("Upgrade ", "");

	return 0;
}

void
close(void)
{
	printf("%s", cmd);
	exit(EXIT_SUCCESS);
}

int
install(string pkgv[], int pkgc)
{
	int size;
	string pkgstr;
	string presub, postsub, tmp, add;

	size = 0;
	for (int i = 0; i < pkgc; i++) {
		if (i == pkgc - 1) {
			size += 1;
		}
		size += strlen(pkgv[i]);
	}

	pkgstr = (string)malloc(size);
	for (int i = 0; i < pkgc; i++) {
		(void)strlcat(pkgstr, pkgv[i], size);
		if (i != pkgc - 1) {
			(void)strlcat(pkgstr, " ", size);
		}
	}

	pkgstr[pkgc] = '\0';

	presub = "apt-get -q install %s || exit 1\n";

	size = strlen(presub) + (strlen(pkgstr) - 2);

	postsub = (string)malloc(size + 1);
	(void)sprintf(postsub, presub, pkgstr);

	cmdc += size;
	if (cmdc - size == icmdc) {
		tmp = (string)malloc(cmdc + 1);
	} else {
		tmp = (string)realloc(cmd, cmdc + 1);
	}
	cmd = tmp;
	(void)strlcat(cmd, postsub, cmdc + 1);
	free(postsub);

	setmsg("Add ", pkgstr);

	return 0;
}

int
commit(void)
{
	int size;
	string presub, postsub, tmp;

	presub =
	    "dpkg-query -Wf '${Package}=${Version}\\n' | sort > %s/packages || exit 1\n"
	    "git --git-dir %s/.git --work-tree=%s/vpk commit -a -m \"%s\" > /dev/null 2>&1 || exit 1\n";

	size = strlen(presub) + 3 * (strlen(vpkpath) - 2) + (strlen(msg) - 2);

	postsub = (string)malloc(size + 1);
	(void)sprintf(postsub, presub, vpkpath, vpkpath, vpkpath, msg);

	cmdc += size;
	if (cmdc - size == icmdc) {
		tmp = (string)malloc(cmdc + 1);
	} else {
		tmp = (string)realloc(cmd, cmdc + 1);
	}
	cmd = tmp;
	(void)strlcat(cmd, postsub, cmdc + 1);
	free(postsub);

	return 0;
}

void
setmsg(string prefix, string suffix)
{
	int size;

	size = strlen(prefix) + strlen(suffix);
	msg = malloc(size + 1);
	(void)strlcpy(msg, prefix, size + 1);
	(void)strlcat(msg, suffix, size + 1);
}