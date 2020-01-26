include config.mk

LIBS = -lcrypt -lbsd -lm
OBJ = main.c commands.h files.h pkgs.h str.h

all: vpk

vpk: $(OBJ)
	$(CC) $(CFLAGS) main.c $(LIBS) -o vpk

clean:
	rm -f vpk vpk-$(VERSION).tar.gz main

dist: clean
	mkdir -p vpk-$(VERSION)
	cp -R LICENSE Makefile config.mk $(OBJ) vpk-$(VERSION)
	tar -czf vpk-$(VERSION).tar.gz vpk-$(VERSION)
	rm -rf vpk-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f vpk $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpk

.PHONY: all vpk clean dist