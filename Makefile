include config.mk

OBJ = main.c vpk.h files.h vpk.h str.h

all: vpkadd vpkrm vpknfo vpkpin

vpkadd: vpkadd.sh
	$(CC) $(CFLAGS) vpkadd.sh > vpkadd
	chmod +x vpkadd

vpkrm: vpkrm.sh
	$(CC) $(CFLAGS) vpkrm.sh > vpkrm
	chmod +x vpkrm

vpknfo: vpknfo.sh
	$(CC) $(CFLAGS) vpknfo.sh > vpknfo
	chmod +x vpknfo

vpkpin: vpkpin.sh
	$(CC) $(CFLAGS) vpkpin.sh > vpkpin
	chmod +x vpkpin

clean:
	rm -f vpkadd vpkrm vpknfo vpkpin

dist: clean
	mkdir -p vpk-$(VERSION)
	cp -R LICENSE config.mk Makefile README.md vpkadd.sh vpknfo.sh vpmrk.sh vpk-$(VERSION) 
	tar -czf vpk-$(VERSION).tar.gz vpk-$(VERSION)
	rm -rf vpk-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/sbin

	cp -f vpkadd $(DESTDIR)$(PREFIX)/sbin
	chmod 755 $(DESTDIR)$(PREFIX)/sbin/vpkadd

	cp -f vpknfo $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpknfo

	cp -f vpkpin $(DESTDIR)$(PREFIX)/sbin
	chmod 755 $(DESTDIR)$(PREFIX)/sbin/vpkpin

	cp -f vpkrm $(DESTDIR)$(PREFIX)/sbin
	chmod 755 $(DESTDIR)$(PREFIX)/sbin/vpkrm

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/vpkadd
	rm -f $(DESTDIR)$(PREFIX)/bin/vpknfo
	rm -f $(DESTDIR)$(PREFIX)/bin/vpkpin
	rm -f $(DESTDIR)$(PREFIX)/bin/vpkrm

.PHONY: all vpk clean dist
