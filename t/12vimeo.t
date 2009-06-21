#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 2;
use Test::clive;

Test::clive::host( qq|http://vimeo.com/1485507|, "-f $_" )
    foreach qw(flv hd);
