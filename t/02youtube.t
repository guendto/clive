#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More tests => 8;
use Test::clive;

Test::clive::host( qq|http://www.youtube.com/watch?v=gb2fUOW1ne4|, "-f $_" )
    foreach qw(flv fmt17 fmt18 fmt22 fmt35);

Test::clive::host(qq|http://www.youtube.com/v/gb2fUOW1ne4|);    # Embed.

Test::clive::host(qq|http://www.youtube-nocookie.com/v/3PuHGKnboNY|);

Test::clive::host(
    qq|http://www.last.fm/music/Rammstein/+videos/+1-3jwXQFFLSHo|);
