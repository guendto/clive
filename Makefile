# GNU Makefile

SHELL = /bin/sh

prefix      = $(HOME)
bindir      = $(prefix)/bin
datarootdir = $(prefix)/share
datadir     = $(datarootdir)
mandir      = $(datarootdir)/man
man1dir     = $(mandir)/man1

INSTALL     = install -c
INSTALL_D   = install -d
INSTALL_M   = install -c -m 444
RM          = rm -f
PERL        = perl
POD2MAN     = pod2man
AWK         = awk
TR          = tr

WITH_MAN    = yes
WITH_CHECK  = yes

ifndef V
QUIET_POD2MAN   = @echo POD2MAN clive.1;
endif

RELEASE := \
    $(shell sh -c "$(AWK) '/constant VERSION/ {print \$$5}' clive | \
        $(TR) -d '[\";]'")

.PHONY: all checks
all: checks

checks:
ifeq ($(WITH_CHECK),yes)
	@echo Check for required Perl modules...
	@echo -n URI::Escape ...
	@echo `$(PERL) -MURI::Escape -e "print 'yes'" 2>/dev/null || \
        echo 'no'`
	@echo -n XML::Simple ...
	@echo `$(PERL) -MXML::Simple -e "print 'yes'" 2>/dev/null || \
        echo 'no'`
	@echo -n WWW::Curl 4.05+ ...
	@echo `$(PERL) -e "use WWW::Curl 4.05; print 'yes'" 2>/dev/null || \
        echo 'no'`
	@echo -n HTML::TokeParser ...
	@echo `$(PERL) -MHTML::TokeParser -e "print 'yes'" 2>/dev/null || \
        echo 'no'`
	@echo -n Config::Tiny ...
	@echo `$(PERL) -MConfig::Tiny -e "print 'yes'" 2>/dev/null || \
        echo 'no'`
	@echo -n BerkeleyDB ...
	@echo `$(PERL) -MBerkeleyDB -e "print 'yes'" 2>/dev/null || \
        echo 'no'`
else
	@echo 'Skip checks.'
endif

.PHONY: install uninstall
install:
	$(INSTALL_D) $(DESTDIR)$(bindir)
	$(INSTALL) clive $(DESTDIR)$(bindir)/clive
ifeq ($(WITH_MAN),yes)
	$(INSTALL_D) $(DESTDIR)$(man1dir)
	$(INSTALL_M) clive.1 $(DESTDIR)$(man1dir)/clive.1
endif

uninstall:
	$(RM) $(DESTDIR)$(bindir)/clive
ifeq ($(WITH_MAN),yes)
	$(RM) $(DESTDIR)$(man1dir)/clive.1
endif

.PHONY: man
man:
	$(QUIET_POD2MAN)$(POD2MAN) -c "clive manual" -n clive \
		-s 1 -r $(RELEASE) clive.pod clive.1
