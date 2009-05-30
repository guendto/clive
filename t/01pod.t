use warnings;
use strict;

use Test::More tests => 1;

SKIP: {
    eval "use Pod::Checker";
    skip 'Pod::Checker required for testing Pod' if $@;

    my $r = podchecker("blib/script/clive");
    ok( $r == 0 )
      or diag explain $r;
}
