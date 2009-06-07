#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 1;
use Test::clive;

Test::clive::host(qq|http://www.redtube.com/11573|);
