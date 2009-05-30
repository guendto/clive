#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 2;
use RunTest;

SKIP: {
    skip 'Set CLIVE_TEST_HOSTS=1', 2 unless $ENV{CLIVE_TEST_HOSTS};
    RunTest::runTest(qq|http://www.liveleak.com/view?i=704_1228511265|);
    RunTest::runTest(qq|http://www.liveleak.com/e/6ff_1228698283|);    # Embed.
}
