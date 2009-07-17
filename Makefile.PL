#!/usr/bin/env perl

use warnings;
use strict;

use ExtUtils::MakeMaker;

my $version = get_version();

WriteMakefile(
    'NAME' => 'clive',
    ( $[ >= 5.8 )
    ? ( AUTHOR     => 'Toni Gundogdu <legatvs@gmail.com>',
        'ABSTRACT' => 'command line video extraction utility'
        )
    : (),
    'VERSION'   => $version,
    'EXE_FILES' => ['bin/clive'],
    'PREREQ_PM' => {
        'Getopt::ArgvFile' => 1.11,
        'Class::Singleton' => 1.4,
        'HTML::TokeParser' => 2.37,
        'URI::Escape'      => 3.29,
        'Digest::SHA'      => 5.45,
        'WWW::Curl'        => 4.05,
    },
    'LICENSE' => 'gpl',
    dist      => {
        COMPRESS => "bzip2",
        SUFFIX   => ".bz2"
    },
);

sub get_version {
    my $file = "lib/clive/Config.pm";
    my $re   = qr/VERSION => "(.*?)"/;
    open my $fh, "<", $file
        or die "$file: $!";
    foreach (<$fh>) {
        close $fh and return $1
            if $_ =~ /$re/;
    }
    close $fh;
    die "$file: `$re`: not matched";
}
