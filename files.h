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
		char c[2] = { (char)i, '\0' };
		(void)strlcat(dst, c, size);
	}

	(void)fclose(fp);

	return 0;
}

int
fileappend(char path[], char buffer[])
{
	FILE *pFile = fopen(path, "a");
	if (pFile == NULL) {
		fprintf(stderr, "E: pFile is null\n");
		return 1;
	}

	int c = fprintf(pFile, "%s", buffer);
	if (c == 0) {
		fprintf(stderr, "E: failed printing to pFile\n");
		return 1;
	}

	int err = fclose(pFile);
	if (err != 0) {
		fprintf(stderr, "E: failed closing file\n");
		return 1;
	}

	return 0;
}

#endif /* FILES_H_ */
