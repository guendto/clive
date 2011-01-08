#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    plan tests => 13;
}
use Test::clive;

Test::clive::host(qq|http://www.youtube.com/v/DUM1284TqFc|);
Test::clive::host(qq|https://www.youtube.com/v/3PuHGKnboNY|);
Test::clive::host(qq|http://www.youtube-nocookie.com/v/3PuHGKnboNY|);
Test::clive::host(qq|http://youtu.be/3PuHGKnboNY|);
Test::clive::host(
    qq|http://www.last.fm/music/Iron+Maiden/+videos/+1-Pje6h_hFPzc|);

Test::clive::host( qq|http://www.youtube.com/watch?v=DUM1284TqFc|, "-f $_" )
    foreach qw(default flv_240p flv_360p flv_480p mp4_360p mp4_720p
    mp4_1080p mp4_3072p);
