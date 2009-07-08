#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    plan tests => 8;
}
use Test::clive;

Test::clive::host( qq|http://www.youtube.com/watch?v=d0j_ONmVcXA|, "-f $_" )
    foreach qw(flv fmt17 fmt18 fmt22 fmt35);

Test::clive::host(qq|http://www.youtube.com/v/d0j_ONmVcXA|);    # Embed.

Test::clive::host(qq|http://www.youtube-nocookie.com/v/3PuHGKnboNY|);

Test::clive::host(
    qq|http://www.last.fm/music/Iron+Maiden/+videos/+1-Pje6h_hFPzc|);
