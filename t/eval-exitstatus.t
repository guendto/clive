#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;

my $clive  = "perl -I./blib/lib blib/script/clive -q";
my $cmd    = "$clive http://nosupport";
my $output = qx($cmd);

my $rc = $? >> 8;
ok( $rc == 2 )
    or diag "$cmd\nexpected return code 2 (got $rc)";
