#!/usr/bin/env perl

use warnings;
use strict;

use 5.008009;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME       => 'clive',
  DISTNAME   => 'clive',
  VERSION_FROM => 'bin/clive',
  PREREQ_PM => {
'Getopt::ArgvFile' => 1.11,
'JSON::XS'         => 2.30,
  },
  BUILD_REQUIRES => {
    'ExtUtils::MakeMaker' => 0,
  },
  CONFIGURE_REQUIRES => {
    'ExtUtils::MakeMaker' => 0,
  },
  MIN_PERL_VERSION => 5.008009,
  ($] >= 5.005 ?
    (ABSTRACT_FROM => 'doc/man1/clive.1.pod',
     AUTHOR => 'Toni Gundogdu <legatvs@cpan.org>') : ()),
  'LICENSE' => 'gpl',
  'EXE_FILES'    => ['bin/clive'],
  'MAN1PODS' =>
    {'doc/man1/clive.1.pod' => '$(INST_MAN1DIR)/clive.$(MAN1EXT)'},
  dist => {
    PREOP => '@if test -f .git/HEAD; then \
	git log --stat --name-only --date=short --abbrev-commit \
		--after="Tue Sep 28 02:13:39 2010" > ChangeLog; \
fi',
    POSTOP => '@if test -f .git/HEAD; then \
	git checkout ChangeLog; \
fi',
    },
);
