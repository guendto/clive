#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    plan tests => 2;
}
use Test::clive;

Test::clive::host( qq|http://vimeo.com/1485507|, "-f $_" ) foreach qw(default hd);
