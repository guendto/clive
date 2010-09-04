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

Test::clive::host( qq|http://www.youtube.com/watch?v=DeWsZ2b_pK4|, "-f $_" )
    foreach qw(default mobile sd_270p sd_360p hq_480p hd_720p hd_1080p);

Test::clive::host(qq|http://www.youtube.com/v/DeWsZ2b_pK4|);    # Embed.

Test::clive::host(qq|http://www.youtube-nocookie.com/v/3PuHGKnboNY|);

Test::clive::host(
    qq|http://www.last.fm/music/Iron+Maiden/+videos/+1-Pje6h_hFPzc|);
