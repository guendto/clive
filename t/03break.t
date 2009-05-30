#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;
use RunTest;

SKIP: {
    skip 'Set CLIVE_TEST_HOSTS=1', 1 unless $ENV{CLIVE_TEST_HOSTS};
    RunTest::runTest(qq|http://break.com/index/beach-tackle-whip-lash.html|);
}
