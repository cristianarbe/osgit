#include <stdlib.h>
#include <string.h>
#include <bsd/string.h>

#include "vpk-cli.h"

int
main(int argc, string argv[])
{

	if (argc == 1) {
		help();
		exit(EXIT_SUCCESS);
	}

	if (strcmp(argv[1], "install") == 0) {
		argv[0] = "vpkadd";
		argv[1] = "";
		int err = shell(argv, argc);
		iferr(err, "vpkadd failed");
	}
}