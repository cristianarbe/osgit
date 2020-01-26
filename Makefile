include config.mk

LIBS = -lcrypt -lbsd -lm
OBJ = main.c commands.h files.h pkgs.h str.h

all: vpm

vpm: $(OBJ)
	$(CC) $(CFLAGS) main.c $(LIBS) -o vpm

clean:
	rm -f vpm vpm-$(VERSION).tar.gz main

dist: clean
	mkdir -p vpm-$(VERSION)
	cp -R LICENSE Makefile config.mk $(OBJ) vpm-$(VERSION)
	tar -czf vpm-$(VERSION).tar.gz vpm-$(VERSION)
	rm -rf vpm-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f vpm $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpm

.PHONY: all vpm clean dist