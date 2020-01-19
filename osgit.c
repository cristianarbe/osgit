/* Copyright 2020 Cristian Ariza */

/* Headers */

#include <bsd/string.h>

#include "./commands.h"
#include "./files.h"
#include "./pkgs.h"

/* Types */

struct prereqs {
	int makemaster, params;
};

struct args {
	char *subcommand;
	char params[100];
};

/* Function declarations */

static int mkmaster(void);
static struct args parseargs(int argc, char *argv[]);
static struct prereqs reqs(char const *subcommand);

/* Main */

int
main(int argc, char *argv[])
{
	struct args command;
	struct prereqs needs;

	if (argc == 1) {
		fprintf(stderr, "E: need at least one parameter\n");
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
	} else if (strcmp(command.subcommand, "import") == 0) {
		printf("importing...\n");

	} else if (strcmp(command.subcommand, "init") == 0) {
		printf("initing...\n");

	} else if (strcmp(command.subcommand, "list") == 0) {
	} else if (strcmp(command.subcommand, "log") == 0) {
		int err = system("/home/cariza/.cache/osgit/ log --oneline");
		if (err != 0) {
			fprintf(stderr, "E: error getting log\n");
			exit(EXIT_FAILURE);
		}

	} else if (strcmp(command.subcommand, "pin") == 0) {
		printf("pining...\n");

	} else if (strcmp(command.subcommand, "revert") == 0) {
		printf("reverting...\n");

	} else if (strcmp(command.subcommand, "rm") == 0) {
		char msg[40] = "";
		char cmd[100] = "";

		(void)strlcpy(
		    cmd, "/usr/bin/apt --autoremove purge", sizeof(cmd));
		(void)strlcat(cmd, command.params, sizeof(cmd));

		int err = system(cmd);
		if (err != 0) {
			fprintf(stderr, "E: error purging\n");
			exit(EXIT_FAILURE);
		}

		(void)strlcpy(msg, "Remove ", sizeof(msg));
		(void)strlcat(msg, command.params, sizeof(msg));
		err = pkgsclose(msg);
		if (err != 0) {
			fprintf(stderr, "E: error closing pkgs\n");
			exit(EXIT_FAILURE);
		}

	} else if (strcmp(command.subcommand, "rollback") == 0) {
		printf("rollbacking...\n");

	} else if (strcmp(command.subcommand, "show") == 0) {
		printf("showing...\n");

	} else if (strcmp(command.subcommand, "unpin") == 0) {
		printf("unpining...\n");

	} else if (strcmp(command.subcommand, "update") == 0) {
		int err = system("/usr/bin/apt update");
		if (err != 0) {
			fprintf(stderr, "E: error updating\n");
			exit(EXIT_FAILURE);
		}

	} else if (strcmp(command.subcommand, "upgrade") == 0) {
		int err = system("/usr/bin/apt update");
		if (err != 0) {
			fprintf(stderr, "E: error updating\n");
			exit(EXIT_FAILURE);
		}
		err = system("/usr/bin/apt upgrade -y");
		if (err != 0) {
			fprintf(stderr, "E: error upgrading\n");
			exit(EXIT_FAILURE);
		}

	} else if (strcmp(command.subcommand, "version") == 0) {
		printf("versioning...\n");

	} else if (strcmp(command.subcommand, "-v") == 0) {
		printf("-ving...\n");

	} else {
		char msg[200];
		help(msg);
		printf("%s", msg);
	}

	return 0;
}

/* Function definitions */

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
	struct args command = { 0, "" };

	for (int i = 1; i < argc; i = i + 1) {
		if (strcmp(argv[i], "-d") == 0) {
			printf("debug active\n");
		} else {
			command.subcommand = argv[i];

			for (int j = i + 1; j < argc; j = j + 1) {
				if (j - i == 50) {
					fprintf(stderr,
					    "E: maximum number of arguments reached (50)");
					exit(EXIT_FAILURE);
				}

				(void)strlcat(command.params, argv[j],
				    sizeof(command.params));
			}

			break;
		}
	}

	return command;
}
