#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;
use RunTest;

RunTest::runTest(qq|http://space.tv.cctv.com/video/VIDE1212909276513233|);
