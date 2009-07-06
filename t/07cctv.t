#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    plan tests => 1;
}
use Test::clive;

Test::clive::host(qq|http://space.tv.cctv.com/video/VIDE1212909276513233|);
