package RunTest;

use Test::More;

my $clive = "perl -I./blib/lib blib/script/clive -n";

sub runTest {
    my $url    = shift;
    my $cmd    = "$clive $url @_ 2>&1";
    my $output = qx($cmd);
    ok( $output !~ /error:/ )
      or diag explain "$cmd\n$output";
}

1;
