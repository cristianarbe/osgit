/* Copyright 2020 Cristian Ariza */

#include <stdio.h>

#ifndef FILES_H_
#define FILES_H_

int
filecpy(char *dst, char *path, size_t size)
{
	int i;
	FILE *fp;

	fp = fopen(path, "r");

	if (fp == NULL) {
		return 1;
	}

	while (i = fgetc(fp), i != EOF) {
		char c[2] = { i, '\0' };
		(void)strlcat(dst, c, size);
	}

	(void)fclose(fp);

	return 0;
}

#endif /* FILES_H_ */
