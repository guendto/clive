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

MODULES = \
 Config::Tiny  WWW::Curl  HTML::TokeParser  BerkeleyDB \
 URI::Escape  Digest::SHA \

MODULES_OPTIONAL = \
 Clipboard  IO::Pager  Expect  Term::ReadKey

checks:
ifeq ($(WITH_CHECK),yes)
	@echo == Required Perl modules:
	@for m in $(MODULES); \
	do \
        result=`$(PERL) -M$$m -e "print 'yes'" 2>/dev/null || echo no`;\
		echo "$$m ...$$result"; \
	done
	@echo == Optional Perl modules:
	@for m in $(MODULES_OPTIONAL); \
	do \
        result=`$(PERL) -M$$m -e "print 'yes'" 2>/dev/null || echo no`;\
		echo "$$m ...$$result"; \
	done
else
	@echo Disable module checks.
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
