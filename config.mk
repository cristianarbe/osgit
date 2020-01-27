CC = clang
CFLAGS = -fsanitize=signed-integer-overflow -fsanitize=undefined -ggdb3 -O0 \
	-std=c11 -Wall -W -Werror -Wextra -Wsign-compare  \
	-Wpointer-arith -Wbad-function-cast -Wunused-variable -Wshadow 
PREFIX = /usr/local
VERSION = v0.7.0