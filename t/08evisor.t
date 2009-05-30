#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;
use RunTest;

SKIP: {
    skip 'Set CLIVE_TEST_HOSTS=1', 1 unless $ENV{CLIVE_TEST_HOSTS};
    RunTest::runTest(
qq|http://www.evisor.tv/tv/rennstrecken/1-runde-oschersleben-14082008--6985.htm|
    );
}
