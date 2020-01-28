#include <stdlib.h>
#include <stdio.h>
#include <bsd/string.h>

typedef char *string;

void die(string msg);

void
die(string msg)
{
	fprintf(stderr, "E: %s\n", msg);
	exit(EXIT_FAILURE);
}

void
iferr(int err, string msg)
{
	if (err != 0) {
		fprintf(stderr, "E: %s\n", msg);
		exit(EXIT_FAILURE);
	}
}

void
help(void)
{
	fprintf(stderr,
	    "osgit v1.0.0\n"
	    "Usage: osgit [options] command\n"
	    "\n"
	    "osgit is a command line apt-wrapper and provides commands for\n"
	    "searching and managing as well as version control installed "
	    "packages.\n"
	    "\n"
	    "Commands:\n"
	    "	add/rm - installs/uninstalls packages\n"
	    "	du - summarise disk usage of installed packages\n"
	    "	help - shows this\n"
	    "	list - lists installed packages\n"
	    "	log - shows osgit commit log\n"
	    "	revert - reverts a specific commit\n"
	    "	update - updates cache\n"
	    "	upgrade - upgrade the system by installing/upgrading packages\n");
}

string
strjoin(string src[], int n)
{
	int chars = n;
	string ret;

	for (int i = 0; i < n; i++) {
		chars += strlen(src[i]);
	}

	ret = (string)malloc(chars);

	for (int pos = 0, i = 0, j = 0;; pos++) {
		if (pos == chars) {
			ret[pos] = '\0';
			break;
		} else if (src[i][j] == '\0') {
			ret[pos] = ' ';
			i++;
			j = 0;
			continue;
		}

		ret[pos] = src[i][j];
		j++;
	}

	return ret;
}

int
shell(string v[], int c)
{
	return system(strjoin(v, c));
}
