#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;
use RunTest;

RunTest::runTest(
    qq|http://www.evisor.tv/tv/rennstrecken/1-runde-oschersleben-14082008--6985.htm|
);
