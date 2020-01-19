FLAGS = -fsanitize=signed-integer-overflow -fsanitize=undefined -ggdb3 -O0 \
	-std=c11 -Wall -W -Werror -Wextra -Wno-sign-compare -Wno-unused-parameter \
	-Wpointer-arith -Wbad-function-cast -Wno-unused-variable -Wshadow 
LIBS = -lcrypt -lbsd -lm

osgit: osgit.c commands.h files.h pkgs.h str.h
	clang $(FLAGS) osgit.c $(LIBS) -o osgit