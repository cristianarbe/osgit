include config.mk

OBJ = main.c vpk.h files.h vpk.h str.h

all: vpkadd vpkrm vpknfo vpkpin vpkadd.1

vpkrm: vpkrm.c vpkrm.h vpkrm.1
	$(CC) $(CFLAGS) -o vpkrm $(CLIBS) vpkrm.c

vpknfo: vpknfo.sh
	$(SC) $(SFLAGS) vpknfo.sh > vpknfo
	chmod +x vpknfo

vpkpin: vpkpin.sh
	$(SC) $(SFLAGS) vpkpin.sh > vpkpin
	chmod +x vpkpin

vpkadd.1: vpkadd.md
	pandoc -s -t man vpkadd.md -o vpkadd.1

vpkrm.1: vpkrm.md
	pandoc -s -t man vpkrm.md -o vpkrm.1

clean:
	rm -f vpkadd vpkrm vpknfo vpkpin vpk-cli vpkadd.1 vpkrm.1

dist: clean
	mkdir -p vpk-$(VERSION)
	cp -R LICENSE config.mk Makefile README.md vpkadd.sh vpknfo.sh vpmrk.sh vpk-$(VERSION) 
	tar -czf vpk-$(VERSION).tar.gz vpk-$(VERSION)
	rm -rf vpk-$(VERSION)

check:
	clang-format -i *.h *.c
	iwyu vpkadd.c
	iwyu vpkrm.c

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/lib

	cp -f vpkadd $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkadd

	cp -f libvpkadd.sh $(DESTDIR)$(PREFIX)/lib

	cp -f vpkadd.1 $(DESTDIR)$(PREFIX)/man/man1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/vpkadd
	rm -f $(DESTDIR)$(PREFIX)/bin/vpknfo
	rm -f $(DESTDIR)$(PREFIX)/bin/vpkpin
	rm -f $(DESTDIR)$(PREFIX)/bin/vpkrm

.PHONY: all vpk clean dist
