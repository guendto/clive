#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 8;
use RunTest;

SKIP: {
    skip 'Set CLIVE_TEST_HOSTS=1', 8 unless $ENV{CLIVE_TEST_HOSTS};

    RunTest::runTest( qq|http://www.youtube.com/watch?v=gb2fUOW1ne4|, "-f $_" )
      foreach qw(flv fmt17 fmt18 fmt22 fmt35);

    RunTest::runTest(qq|http://www.youtube.com/v/gb2fUOW1ne4|);    # Embed.

    RunTest::runTest(qq|http://www.youtube-nocookie.com/v/3PuHGKnboNY|);

    RunTest::runTest(
        qq|http://www.last.fm/music/Rammstein/+videos/+1-3jwXQFFLSHo|);
}
