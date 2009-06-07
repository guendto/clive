#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;
use Test::clive;

Test::clive::host(
    qq|http://www.last.fm/music/Johnny+Cash/+videos/+1-AOtl60OOhsM|);
