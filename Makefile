include config.mk

OBJ = vpkadd vpkadd.1 vpkrm vpkrm.1 vpkinfo vpkinfo.1

all: $(OBJ)

vpkadd: vpkadd.sh
	@$(SC) $(SFLAGS) vpkadd.sh > vpkadd
	@chmod +x vpkadd

vpkadd.1: vpkadd.md
	@$(MC) $(MFLAGS) -o vpkadd.1 vpkadd.md

vpkrm: vpkrm.sh
	@$(SC) $(SFLAGS) vpkrm.sh > vpkrm
	@chmod +x vpkrm

vpkrm.1: vpkrm.md
	@$(MC) $(MFLAGS) -o vpkrm.1 vpkrm.md

vpkinfo: vpkinfo.sh
	@$(SC) $(SFLAGS) vpkinfo.sh > vpkinfo
	@chmod +x vpkinfo

vpkinfo.1: vpkinfo.md
	@$(MC) $(MFLAGS) -o vpkinfo.1 vpkinfo.md

clean: 
	@rm -f $(OBJ)

dist: clean
	@mkdir -p vpkutils-$(VERSION)
	@cp -R config.mk LICENSE Makefile vpkadd.sh vpkadd.md vpkinfo.sh \
	vpkinfo.md vpkrm.sh vpkrm.md vpk-$(VERSION) 
	@tar -czf vpk-$(VERSION).tar.gz vpk-$(VERSION)
	@rm -rf vpk-$(VERSION)

install: all Makefile
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -f vpkadd vpkrm vpkinfo $(DESTDIR)$(PREFIX)/bin
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkadd
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkrm
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/vpkinfo

	@mkdir -p $(DESTDIR)$(PREFIX)/man/man1
	@cp -f vpkadd.1 vpkrm.1 vpkinfo.1 $(DESTDIR)$(PREFIX)/man/man1

uninstall: Makefile
	@rm -f $(DESTDIR)$(PREFIX)/bin/vpkadd
	@rm -f $(DESTDIR)$(PREFIX)/bin/vpkadd
	@rm -f $(DESTDIR)$(PREFIX)/bin/vpkinfo
	@rm -f $(DESTDIR)$(PREFIX)/man/man1/vpkadd.1
	@rm -f $(DESTDIR)$(PREFIX)/man/man1/vpkadd.1
	@rm -f $(DESTDIR)$(PREFIX)/man/man1/vpkinfo.1

.PHONY: all clean dist install uninstall
