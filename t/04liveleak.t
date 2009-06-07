#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 2;
use RunTest;

RunTest::runTest(qq|http://www.liveleak.com/view?i=704_1228511265|);
RunTest::runTest(qq|http://www.liveleak.com/e/6ff_1228698283|);    # Embed.
