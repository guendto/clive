#!/usr/bin/env perl

use warnings;
use strict;

use 5.008009;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'clive',
  DISTNAME     => 'clive',
  VERSION_FROM => 'lib/clive/Config.pm',
  PREREQ_PM  => {
                  'Getopt::ArgvFile' => 1.11,
                  'Class::Singleton' => 1.4,
                  'HTML::TokeParser' => 2.37,
                  'URI::Escape'      => 3.29,
                  'Digest::SHA'      => 5.45,
                  'WWW::Curl'        => 4.05,
                  'Config::Tiny'     => 2.12,
                 },
  BUILD_REQUIRES     => {'ExtUtils::MakeMaker' => 0,},
  CONFIGURE_REQUIRES => {'ExtUtils::MakeMaker' => 0,},
  MIN_PERL_VERSION   => 5.008009,
  (
   $] >= 5.005
   ? (
      ABSTRACT_FROM => 'man1/clive.1.pod',
      AUTHOR        => 'Toni Gundogdu <legatvs@cpan.org>'
     )
   : ()
  ),
  LICENSE   => 'gpl',
  EXE_FILES => ['bin/clive'],
  MAN1PODS =>
    {'man1/clive.1.pod' => '${INST_MAN1DIR}/clive.$(MAN1EXT)'},
  dist => {
    PREOP => '@if test -f .git/HEAD; then \
	git log --stat --name-only --date=short --abbrev-commit \
		--after="Tue Nov 30 14:02:38 2010" >ChangeLog; \
fi',
    POSTOP => '@if test -f .git/HEAD; then \
	git checkout ChangeLog; \
fi',
  },
);
