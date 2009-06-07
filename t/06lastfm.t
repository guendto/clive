#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;
use RunTest;

RunTest::runTest(
    qq|http://www.last.fm/music/Johnny+Cash/+videos/+1-AOtl60OOhsM|);
