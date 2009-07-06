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
    qq|http://video.google.com/videoplay?docid=-8669127848070159803|,
    "-f $_" )
    foreach qw(flv mp4);

Test::clive::host(             # Embed.
    qq|http://video.google.com/googleplayer.swf?docid=-8669127848070159803|
);
