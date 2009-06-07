package Test::clive;

use Test::More;

my $clive = "perl -I./blib/lib blib/script/clive -n";

sub host {
    my $url    = shift;
    my $cmd    = "$clive $url @_ 2>&1";
    my $output = qx($cmd);
    ok( $output !~ /error:/ )
      or diag "$cmd\n$output";
}

1;
