#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    if (!$ENV{ADULT_OK}) {
        plan skip_all => "Do not test adult websites";
    }
    plan tests => 1;
}
use Test::clive;

Test::clive::host(qq|http://www.redtube.com/3644|);
