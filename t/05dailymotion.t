#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    plan tests => 5;
}
use Test::clive;

foreach (qw(flv spark-mini h264-hq h264-hd h264)) {
    Test::clive::host(
        qq|http://www.dailymotion.com/hd/video/|
            . qq|x9fkzj_battlefield-1943-coral-sea-trailer_videogames|,
        "-f $_"
    );
}
