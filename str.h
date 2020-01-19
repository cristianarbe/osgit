#include <stdio.h>
#include <bsd/string.h>

void
strjoin(char *dst, char *src[], size_t size)
{
	for (int i = 0; i < size; i++) {
		(void)strlcat(dst, src[i], sizeof(dst));

		if (i == size - 1) {
			break;
		}

		(void)strlcat(dst, " ", sizeof(dst));
	}
}