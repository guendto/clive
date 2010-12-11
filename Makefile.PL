#!/usr/bin/env perl

use warnings;
use strict;

use 5.008009;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'clive',
    ( $[ >= 5.8 )
    ? ( AUTHOR     => 'Toni Gundogdu <legatvs at sign gmail com>',
        'ABSTRACT' => 'command line video downloading tool'
        )
    : (),
    'VERSION_FROM' => 'lib/clive/Config.pm',
    'EXE_FILES'    => ['bin/clive'],
    'PREREQ_PM' => {
        'Getopt::ArgvFile' => 1.11,
        'Class::Singleton' => 1.4,
        'HTML::TokeParser' => 2.37,
        'URI::Escape'      => 3.29,
        'Digest::SHA'      => 5.45,
        'WWW::Curl'        => 4.05,
        'Config::Tiny'     => 2.12,
        'version'          => 0.77
    },
    'LICENSE' => 'gpl',
    'MAN1PODS' => {
        'man1/clive.1.pod' => '${INST_MAN1DIR}/clive.$(MAN1EXT)' },
    dist      => {
        PREOP    =>
'@if test -f .git/HEAD; then \
	git log --stat --after="Tue Nov 30 14:02:38 2010" >ChangeLog; \
fi',
        POSTOP   =>
'@if test -f .git/HEAD; then \
	git checkout ChangeLog; \
fi',
    },
);
