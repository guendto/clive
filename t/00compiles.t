use warnings;
use strict;

use Test::More qw(no_plan);

my $output = qx(perl -c -I./blib/lib blib/script/clive 2>&1);

ok( $output =~ /syntax OK$/ )
  or diag explain $output;
