#include "files.h"

#ifndef LOG_H_
#define LOG_H_

void
logerr(char msg[])
{
	fileappend("/var/log/vpk/vpk.log", msg);
}

#endif /* LOG_H_ */