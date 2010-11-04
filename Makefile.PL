#!/usr/bin/env perl

use warnings;
use strict;

use 5.008009;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'clive',
    ( $[ >= 5.8 )
    ? ( AUTHOR     => 'Toni Gundogdu <legatvs at sign gmail com>',
        'ABSTRACT' => 'command line video extraction utility'
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
    dist      => {
        COMPRESS => "bzip2",
        SUFFIX   => ".bz2"
    },
);
