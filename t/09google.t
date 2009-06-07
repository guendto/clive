#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 3;
use RunTest;

RunTest::runTest(
    qq|http://video.google.com/videoplay?docid=-8669127848070159803|,
    "-f $_" )
    foreach qw(flv mp4);

RunTest::runTest(              # Embed.
    qq|http://video.google.com/googleplayer.swf?docid=-8669127848070159803|
);
