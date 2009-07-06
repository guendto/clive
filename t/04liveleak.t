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

Test::clive::host(qq|http://www.liveleak.com/view?i=704_1228511265|);
Test::clive::host(qq|http://www.liveleak.com/e/6ff_1228698283|);    # Embed.
