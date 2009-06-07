#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 2;
use Test::clive;

Test::clive::host(qq|http://www.liveleak.com/view?i=704_1228511265|);
Test::clive::host(qq|http://www.liveleak.com/e/6ff_1228698283|);    # Embed.
