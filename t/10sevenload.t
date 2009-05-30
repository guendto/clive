#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 5;
use RunTest;

SKIP: {
    skip 'Set CLIVE_TEST_HOSTS=1', 4 unless $ENV{CLIVE_TEST_HOSTS};

    RunTest::runTest(
        qq|http://en.sevenload.com/videos/IUL3gda-Funny-Football-Clips|);
    RunTest::runTest(
qq|http://de.sevenload.com/videos/GN4Hati/EM08-Spanien-Russland-4-1-Highlights|
    );
    RunTest::runTest(
qq|http://en.sevenload.com/shows/TheSailingChannel-TV/episodes/zLM5OvT-Cruising-with-Bettie-Trailer|
    );
    RunTest::runTest(
qq|http://de.sevenload.com/sendungen/halbzeit-in/folgen/Kbv3CsN-Wechselgesang-Sieger-beste-Bewertungen|
    );

    # Embed.
    RunTest::runTest(
        qq|http://en.sevenload.com/pl/IUL3gda-Funny-Football-Clips|);
}
