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

Test::clive::host(qq|http://break.com/index/beach-tackle-whip-lash.html|);
