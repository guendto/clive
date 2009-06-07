#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 6;
use Test::clive;

foreach (qw(flv spak-mini vp6-hq vp6-hd vp6 h264)) {
    Test::clive::host(
        qq|http://www.dailymotion.com/hd/video/|
            . qq|x9fkzj_battlefield-1943-coral-sea-trailer_videogames|,
        "-f $_"
    );
    sleep(5);
}
