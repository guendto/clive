# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
# Copyright 2007, 2008, 2009 Toni Gundogdu.
#
# This file is part of clive.
#
# clive is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# clive is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
###########################################################################

# Original: anonprn2@gmail.com

package clive::Host::Redtube;

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("redtube");

    # extracts a given digit from a number.
    # len specifies the desired length of the number.
    # for example, if $num is 447, $digit is 4, $len is 7,
    # we extract 4th digit (starting at 0, counting from the left)
    # in '0000447', which happens to be '4'.
    sub digit {
        my ( $num, $digit, $len ) = @_;

        my $foo = sprintf( "%0$len" . "d", $num );

        return substr( $foo, $digit, 1 );
    }

    my %re = (
        id    => qr|videoid=(.*?)'|,
        title => qr|videotitle'>(.*?)</|i
    );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {

        my $id = $tmp->{id};

        # the code below was inspired by
        # http://iescripts.org/view-scripts-61p5.htm

        # some predefined mapping array, it seems
        my @map = unpack( 'C*', 'R15342O7K9HBCDXFGAIJ8LMZ6PQ0STUVWEYN' );

        my $var_1 = 0;
        for ( my $i = 0; $i <= 6; $i++ ) {

            #        0000477
            #        0 --> 0*1 = 0
            #        0 --> 0*2 = 0
            #        0 --> 0*3 = 0
            #        0 --> 0*4 = 0
            #        4 --> 4*5 = 20
            #        7 --> 7*6 = 42
            #        7 --> 7*7 = 49
            #        $ var_1 = 20+42+49 = 62+49 = 100+2+9=111

            $var_1 += digit( $id, $i, 7 ) * ( $i + 1 );
        }

        my $var_2 = 0;
        for ( my $i = 0; $i < length($var_1); $i++ ) {

            # $var_1 = 111 -> $var_2 = 3
            $var_2 += digit( $var_1, $i, length($var_1) );
        }

        #    $id = "0000477"
        #    $var_2 = 3
        #    char codes: 0=48 1=49 2=50 3=51 4=52 5=52 6=54 7=55 8=56 9=57

        my @mapping = ();

        push @mapping, $map[ digit( $id, 3, 7 ) + $var_2 + 3 ];
        push @mapping, 48 + $var_2 % 10;
        push @mapping, $map[ digit( $id, 0, 7 ) + $var_2 + 2 ];
        push @mapping, $map[ digit( $id, 2, 7 ) + $var_2 + 1 ];
        push @mapping, $map[ digit( $id, 5, 7 ) + $var_2 + 6 ];
        push @mapping, $map[ digit( $id, 1, 7 ) + $var_2 + 5 ];
        push @mapping, 48 + $var_2 / 10;
        push @mapping, $map[ digit( $id, 4, 7 ) + $var_2 + 7 ];
        push @mapping, $map[ digit( $id, 6, 7 ) + $var_2 + 4 ];

        my $xurl
            = sprintf(
            "http://dl.redtube.com/_videos_t4vn23s9jc5498tgj49icfj4678/%07d/"
                . "%s.flv",
            $id / 1000, pack( 'C*', @mapping ) );

        $$props->video_id($id);
        $$props->video_link($xurl);

        # <title> no longer contains the video title. Use the string
        # extracted from the html instead.
        $$props->page_title( undef, $tmp->{title} );

        return (0);
    }
    return (1);
}

1;

# Run on for a long time, run on for a long time.
