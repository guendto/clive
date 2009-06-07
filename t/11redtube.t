#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;
use RunTest;

RunTest::runTest(qq|http://www.redtube.com/11573|);
