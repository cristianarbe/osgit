include config.mk

OBJ = main.c vpk.h files.h vpk.h str.h

all: vpkadd vpkrm vpkinfo vpkinit

vpkadd: vpkadd.sh
	$(CC) $(CFLAGS) vpkadd.sh > vpkadd
	chmod +x vpkadd

vpkrm: vpkrm.sh
	$(CC) $(CFLAGS) vpkrm.sh > vpkadd
	chmod +x vpkadd

vpkinfo: vpkinfo.sh
	$(CC) $(CFLAGS) vpkinfo.sh > vpkinfo
	chmod +x vpkinfo

vpkinit: vpkinit.sh
	$(CC) $(CFLAGS) vpkinit.sh > vpkinit
	chmod +x vpkinit

clean:
	rm -f vpkadd vpkinfo vpkinit vpkrm

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