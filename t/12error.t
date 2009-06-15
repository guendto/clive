#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;

my $clive  = "perl -I./blib/lib blib/script/clive";
my $cmd    = "$clive http://nosupport";
my $output = qx($cmd);

my $rc = $? >> 8;
ok( $rc == 1 )
    or diag "$cmd\nexpected return code 1 (got $rc)";
