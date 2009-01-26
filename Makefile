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
QUIET_POD2MAN   = @echo '  ' POD2MAN clive.1;
endif

.PHONY: all
all:

m_URIEscape := \
    $(shell sh -c "$(PERL) -MURI::Escape -e 1 2>/dev/null || \
        echo 'no'")
m_XMLSimple := \
    $(shell sh -c "$(PERL) -MXML::Simple -e 1 2>/dev/null || \
        echo 'no'")
m_WWWCurl := \
    $(shell sh -c "$(PERL) -e 'use WWW::Curl 4.05' 2>/dev/null || \
        echo 'no'")
m_HTMLTokeParser:= \
    $(shell sh -c "$(PERL) -MHTML::TokeParser -e 1 2>/dev/null || \
        echo 'no'")
m_ConfigTiny := \
    $(shell sh -c "$(PERL) -MConfig::Tiny -e 1 2>/dev/null || \
        echo 'no'")
m_BerkeleyDB := \
    $(shell sh -c "$(PERL) -MBerkeleyDB -e 1 2>/dev/null || \
        echo 'no'")

RELEASE := \
    $(shell sh -c "$(AWK) '/constant VERSION/ {print \$$5}' clive | \
        $(TR) -d '[\";]'")

.PHONY: checkmods install uninstall
checkmods:
	@echo checking...
ifeq ($(m_URIEscape),no)
	@echo URI::Escape module not found
endif
ifeq ($(m_XMLSimple),no)
	@echo XML::Simple module not found
endif
ifeq ($(m_WWWCurl),no)
	@echo WWW::Curl (4.05+) module not found
endif
ifeq ($(m_HTMLTokeParser),no)
	@echo HTML::TokeParser module not found
endif
ifeq ($(m_ConfigTiny),no)
	@echo Config::Tiny module not found
endif
ifeq ($(m_BerkeleyDB),no)
	@echo BerkeleyDB module not found
endif
	@echo done.

install:
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -C clive $(DESTDIR)$(bindir)/clive
ifeq ($(WITH_MAN),yes)
	$(INSTALL) -d $(DESTDIR)$(mandir)
	$(INSTALL) -C -m 444 clive.1 $(DESTDIR)$(man1dir)/clive.1
endif

uninstall:
	$(RM) $(DESTDIR)$(bindir)/clive
ifeq ($(WITH_MAN),yes)
	$(RM) $(DESTDIR)$(man1dir)/clive.1
endif

.PHONY: man
man:
	$(QUIET_POD2MAN)$(POD2MAN) -c "clive manual" -n clive \
		-s 1 -r $(RELEASE) clive clive.1
