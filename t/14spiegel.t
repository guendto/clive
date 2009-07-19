#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    plan tests => 10;
}
use Test::clive;

Test::clive::host(qq|http://www.spiegel.de/video/video-1012584.html|,"-f $_" )
    foreach qw(flv vp6_64 vp6_388 vp6_576 vp6_928 h264_1400 3gp small iphone podcast);

