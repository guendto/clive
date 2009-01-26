# GNU Makefile

SHELL = /bin/sh

prefix      = $(HOME)
bindir      = $(prefix)/bin
datarootdir = $(prefix)/share
datadir     = $(datarootdir)
mandir      = $(datarootdir)/man
man1dir     = $(mandir)/man1

INSTALL     = install
RM          = rm -f
PERL        = perl
POD2MAN     = pod2man
AWK         = awk
TR          = tr

WITH_MAN    = yes

ifndef V
QUIET_POD2MAN   = @echo POD2MAN clive.1;
endif

RELEASE := \
    $(shell sh -c "$(AWK) '/constant VERSION/ {print \$$5}' clive | \
        $(TR) -d '[\";]'")

.PHONY: all checks
all: man checks

checks:
	@echo Checking for module deps...
	@echo -n URI::Escape ...
	@echo `$(PERL) -MURI::Escape -e "print 'OK'" 2>/dev/null || \
        echo 'no'`
	@echo -n XML::Simple ...
	@echo `$(PERL) -MXML::Simple -e "print 'OK'" 2>/dev/null || \
        echo 'no'`
	@echo -n WWW::Curl 4.05+ ...
	@echo `$(PERL) -e "use WWW::Curl 4.05; print 'OK'" 2>/dev/null || \
        echo 'no'`
	@echo -n HTML::TokeParser ...
	@echo `$(PERL) -MHTML::TokeParser -e "print 'OK'" 2>/dev/null || \
        echo 'no'`
	@echo -n Config::Tiny ...
	@echo `$(PERL) -MConfig::Tiny -e "print 'OK'" 2>/dev/null || \
        echo 'no'`
	@echo -n BerkeleyDB ...
	@echo `$(PERL) -MBerkeleyDB -e "print 'OK'" 2>/dev/null || \
        echo 'no'`
	@echo done. If all checked OK, run \"make install\". See INSTALL for notes.

.PHONY: install uninstall
install:
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -c clive $(DESTDIR)$(bindir)/clive
ifeq ($(WITH_MAN),yes)
	$(INSTALL) -d $(DESTDIR)$(mandir)
	$(INSTALL) -c -m 444 clive.1 $(DESTDIR)$(man1dir)/clive.1
endif

uninstall:
	$(RM) $(DESTDIR)$(bindir)/clive
ifeq ($(WITH_MAN),yes)
	$(RM) $(DESTDIR)$(man1dir)/clive.1
endif

.PHONY: man clean
man:
	$(QUIET_POD2MAN)$(POD2MAN) -c "clive manual" -n clive \
		-s 1 -r $(RELEASE) clive clive.1

clean:
	@$(RM) clive.1 2>/dev/null
