/* Copyright 2020 Cristian Ariza */

/* Headers */

#include <bsd/string.h>

#include "./commands.h"
#include "./files.h"
#include "./pkgs.h"
#include "./str.h"

/* Types */

struct prereqs {
	int makemaster, params;
};

struct args {
	char *subcommand, params[100];
};

/* Function declarations */

static int mkmaster(void);
static struct args parseargs(int argc, char *argv[]);
static struct prereqs reqs(char const *subcommand);
static void help(void);

/* Main */

int
main(int argc, char *argv[])
{
	struct args command;
	struct prereqs needs;

	if (argc == 1) {
		help();
		exit(EXIT_FAILURE);
	}

	command = parseargs(argc, argv);

	if (strcmp(command.subcommand, "") == 0) {
		fprintf(stderr, "E: no subcommand\n");
		exit(EXIT_FAILURE);
	}

	needs = reqs(command.subcommand);

	if (needs.makemaster != 0) {
		int err = mkmaster();
		if (err != 0) {
			fprintf(stderr, "E: failed making master");
			exit(EXIT_FAILURE);
		}
	}

	if (needs.params != 0 && argc < 3) {
		fprintf(stderr, "E: not enough arguments\n");
		exit(EXIT_FAILURE);
	}

	if (strcmp(command.subcommand, "add") == 0) {
		int err = pkgsadd(command.params);
		if (err != 0) {
			fprintf(stderr, "E: failed adding packages\n");
			exit(EXIT_FAILURE);
		}

	} else if (strcmp(command.subcommand, "du") == 0) {
		int err = pkgsdu();
		if (err != 0) {
			fprintf(stderr, "E: failed getting packages usage");
			exit(EXIT_FAILURE);
		}
	} else if (strcmp(command.subcommand, "list") == 0) {
		pkgslist();
	} else if (strcmp(command.subcommand, "log") == 0) {
		int err = pkgslog();
		if (err != 0) {
			fprintf(stderr, "E: failed getting log");
			return 1;
		}
	} else if (strcmp(command.subcommand, "rm") == 0) {
		int err = pkgsrm(command.params);
		if (err != 0) {
			fprintf(stderr, "E: failed removing packages");
			return 1;
		}
	} else if (strcmp(command.subcommand, "update") == 0) {
		int err = system("/usr/bin/apt update");
		if (err != 0) {
			fprintf(stderr, "E: error updating\n");
			exit(EXIT_FAILURE);
		}

	} else if (strcmp(command.subcommand, "upgrade") == 0) {
		int err = pkgsupgrade();
		if (err != 0) {
			fprintf(stderr, "E: failed upgrading packages\n");
			exit(EXIT_FAILURE);
		}
	} else {
		help();
		exit(EXIT_FAILURE);
	}

	return 0;
}

/* Function definitions */

static int
mkmaster(void)
{
	char currentbranch[20] = "";
	char cmd[100] = "";

	int err = filecpy(currentbranch, "/home/cariza/.cache/osgit/.git/HEAD",
	    sizeof(currentbranch));
	if (err != 0) {
		fprintf(stderr, "E: failed reading file contents");
		return 1;
	}

	if (strcmp(currentbranch, "") == 0) {
		fprintf(stderr, "E: can't find current branch");
		exit(EXIT_FAILURE);
	}

	if (strstr(currentbranch, "master") == NULL) {
		err = system(
		    "git --git-dir=/home/cariza/.cache/osgit/.git "
		    "--work-tree=/home/cariza/.cache/osgit/ checkout master");
		if (err != 0) {
			return 1;
		}

		(void)strlcpy(cmd,
		    "git --git-dir=/home/cariza/.cache/osgit/.git "
		    "--work-tree=/home/cariza/.cache/osgit/ reset --hard",
		    sizeof(cmd));
		err = system(cmd);
		if (err != 0) {
			return 1;
		}
	}

	return 0;
}

static struct args
parseargs(int argc, char *argv[])
{
	struct args command = { "", "" };

	for (int i = 1; i < argc; i = i + 1) {
		if (strcmp(argv[i], "-d") == 0) {
			printf("debug active\n");
		} else if (strcmp(command.subcommand, "") == 0) {
			command.subcommand = argv[i];
		} else {
			char *subargv[argc - i];

			memcpy(subargv, &argv[i], 2 * sizeof(*subargv));
			strjoin(command.params, subargv, argc - i);

			break;
		}
	}

	return command;
}

struct prereqs
reqs(char const *subcommand)
{
	struct prereqs result = { 0, 0 };

	if (strcmp(subcommand, "add") == 0) {
		result.makemaster = 1;
	} else if (strcmp(subcommand, "import") == 0) {
		result.makemaster = 1;
		result.params = 1;
	} else if (strcmp(subcommand, "pin") == 0) {
		result.makemaster = 1;
		result.params = 1;
	} else if (strcmp(subcommand, "revert") == 0) {
		result.makemaster = 1;
		result.params = 1;
	} else if (strcmp(subcommand, "rm") == 0) {
		result.makemaster = 1;
		result.params = 1;
	} else if (strcmp(subcommand, "rollback") == 0) {
		result.makemaster = 1;
		result.params = 1;
	} else if (strcmp(subcommand, "unpin") == 0) {
		result.makemaster = 1;
		result.params = 1;
	} else if (strcmp(subcommand, "update") == 0) {
		result.makemaster = 1;
	} else if (strcmp(subcommand, "upgrade") == 0) {
		result.makemaster = 1;
	} else if (strcmp(subcommand, "versions") == 0) {
		result.params = 1;
	}

	return result;
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