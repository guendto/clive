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

Test::clive::host(
    qq|http://en.sevenload.com/videos/IUL3gda-Funny-Football-Clips|);
Test::clive::host(
    qq|http://de.sevenload.com/videos/GN4Hati/EM08-Spanien-Russland-4-1-Highlights|
);
Test::clive::host(
    qq|http://en.sevenload.com/shows/TheSailingChannel-TV/episodes/zLM5OvT-Cruising-with-Bettie-Trailer|
);
Test::clive::host(
    qq|http://de.sevenload.com/sendungen/halbzeit-in/folgen/Kbv3CsN-Wechselgesang-Sieger-beste-Bewertungen|
);

# Embed.
Test::clive::host(
    qq|http://en.sevenload.com/pl/IUL3gda-Funny-Football-Clips|);
