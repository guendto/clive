#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    plan tests => 3;
}
use Test::clive;

Test::clive::host(
    qq|http://video.golem.de/internet/2174/firefox-3.5-test.html|,
    "-f $_" )
    foreach qw(default high ipod);

