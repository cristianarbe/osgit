include config.mk

OBJ = main.c vpk.h files.h vpk.h str.h

all: vpkadd vpkrm vpkinfo vpkinit vpkpin

vpkadd: vpkadd.sh
	$(CC) $(CFLAGS) vpkadd.sh > vpkadd
	chmod +x vpkadd

vpkrm: vpkrm.sh
	$(CC) $(CFLAGS) vpkrm.sh > vpkrm
	chmod +x vpkrm

vpkinfo: vpkinfo.sh
	$(CC) $(CFLAGS) vpkinfo.sh > vpkinfo
	chmod +x vpkinfo

vpkinit: vpkinit.sh
	$(CC) $(CFLAGS) vpkinit.sh > vpkinit
	chmod +x vpkinit

vpkpin: vpkpin.sh
	$(CC) $(CFLAGS) vpkpin.sh > vpkpin
	chmod +x vpkpin

clean:
	rm -f vpkadd vpkrm vpkinfo vpkinit vpkpin

dist: clean
	mkdir -p vpk-$(VERSION)
	cp -R LICENSE config.mk Makefile README.md vpkadd.sh vpkinfo.sh vpkinit.sh vpmrk.sh vpk-$(VERSION) 
	tar -czf vpk-$(VERSION).tar.gz vpk-$(VERSION)
	rm -rf vpk-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f vpkadd $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkadd
	cp -f vpkinfo $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkinfo
	cp -f vpkinit $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkinit
	cp -f vpkpin $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkpin
	cp -f vpkrm $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkrm

.PHONY: all vpk clean dist
