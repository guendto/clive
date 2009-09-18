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

Test::clive::host(
    qq|http://www.myubo.com/page/media_detail.html?movieid=1308f0fb-47c6-40c5-a6f9-1324dac12896|
);
