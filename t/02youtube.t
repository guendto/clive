#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 6;
use RunTest;

SKIP: {
    skip 'Set CLIVE_TEST_HOSTS=1', 6 unless $ENV{CLIVE_TEST_HOSTS};

    RunTest::runTest( qq|http://www.youtube.com/watch?v=gb2fUOW1ne4|, "-f $_" )
      foreach qw(flv mp4 fmt17 fmt22 fmt35);

    RunTest::runTest(qq|http://www.youtube.com/v/gb2fUOW1ne4|);    # Embed.
}
