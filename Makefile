include config.mk

OBJ = main.c vpk.h files.h vpk.h str.h

all: vpkadd vpkadd.1 vpkrm vpkrm.1 vpkinfo vpkinfo.1 Makefile

vpkadd: vpkadd.sh vpkaddh.sh pathnames.sh Makefile
	@$(SC) vpkadd.sh > vpkadd
	@chmod +x vpkadd

vpkadd.1: vpkadd.md Makefile
	@$(MC) $(MFLAGS) -o vpkadd.1 vpkadd.md

vpkrm: vpkrm.sh vpkrmh.sh pathnames.sh Makefile
	@$(SC) vpkrm.sh > vpkrm
	@chmod +x vpkrm

vpkrm.1: vpkrm.md Makefile
	@$(MC) $(MFLAGS) -o vpkrm.1 vpkrm.md

vpkinfo: vpkinfo.sh vpkinfoh.sh pathnames.sh Makefile
	@$(SC) vpkinfo.sh > vpkinfo
	@chmod +x vpkinfo

vpkinfo.1: vpkinfo.md Makefile
	@$(MC) $(MFLAGS) -o vpkinfo.1 vpkinfo.md

clean: Makefile
	@rm -f vpkadd vpkrm vpkinfo vpkpin vpk-cli vpkadd.1 vpkrm.1 vpkinfo.1

dist: clean Makefile
	@mkdir -p vpkutils-$(VERSION)
	@cp -R config.mk LICENSE Makefile pathnames.h shsl vpkadd.md vpkadd.sh vpkaddh.sh vpkinfo.sh vpkrm.md vpkrm.sh vpk-$(VERSION) 
	@tar -czf vpk-$(VERSION).tar.gz vpk-$(VERSION)
	@rm -rf vpk-$(VERSION)

install: all Makefile
	@mkdir -p $(DESTDIR)$(PREFIX)/bin

	@cp -f vpkadd $(DESTDIR)$(PREFIX)/bin
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkadd
	@cp -f vpkadd.1 $(DESTDIR)$(PREFIX)/man/man1

	@cp -f vpkrm $(DESTDIR)$(PREFIX)/bin
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkrm
	@cp -f vpkrm.1 $(DESTDIR)$(PREFIX)/man/man1

	@cp -f vpkinfo $(DESTDIR)$(PREFIX)/bin
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkinfo
	@cp -f vpkinfo.1 $(DESTDIR)$(PREFIX)/man/man1

uninstall: Makefile
	@rm -f $(DESTDIR)$(PREFIX)/bin/vpkadd
	@rm -f $(DESTDIR)$(PREFIX)/bin/vpkinfo
	@rm -f $(DESTDIR)$(PREFIX)/bin/vpkrm

.PHONY: all clean dist uninstall
