#!/usr/bin/env perl -I./t/lib

use warnings;
use strict;

use Test::More;
if ( $ENV{NO_INTERNET} ) {
    plan skip_all => "No internet during package build";
}
else {
    plan tests => 2;
}
use Test::clive;

Test::clive::host(
    qq|http://en.sevenload.com/videos/IUL3gda-Funny-Football-Clips|);

# Embed.
Test::clive::host(
    qq|http://en.sevenload.com/pl/IUL3gda-Funny-Football-Clips|);
