# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
#
# Copyright 2009 Toni Gundogdu.
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
package clive::Host::Cctv;

use warnings;
use strict;

use clive::Error qw(CLIVE_MARKEDBROKEN);

use constant BROKEN_MSG => "Marked as broken.";

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    # Marked as "broken."

    clive::Log->instance->err( CLIVE_MARKEDBROKEN, BROKEN_MSG );
    return 1;

    $$props->video_host("cctv");

    my %re = ( id => qr|videoId=(.*?)&| );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {
        my $domain = join( '.', clive::Util::toDomain( $$props->page_link ) );
        my $config
            = "http://$domain/playcfg/flv_info_new.jsp?videoId=$tmp->{id}";

        my $curl = clive::Curl->instance;

        my $content;
        if ( $curl->fetchToMem( $config, \$content, "config" ) == 0 ) {

            use constant PREFIX => "http://v.cctv.com/flash/";

            # Until a better way can be found.
            if ( $content =~ /"chapters":\[(.*?)\]/ ) {
                my @arr = ( $1 =~ /"url":"(.*?)"/g );
                if ( scalar @arr == 1 ) {
                    $$props->video_id( $tmp->{id} );
                    $$props->video_link( PREFIX . $arr[0] );
                    return (0);
                }

                # We'd parse this from content-type header when
                # video links are verified. Since we skip that,
                # we will have to apply voodoo here.
                my $i = 0;
                foreach (@arr) {

                    # Figure out suffix.
                    my $suffix = "flv";
                    $suffix = $2 if ( $_ =~ /(.*)\.(\w+)$/ );

                    # Append video segment index to the filename.
                    $$props->formatOutputFilename( $suffix, ++$i );

                    # Dump.
                    printf( "video-segment:\t%s\t%s$_\n",
                        $$props->{base_filename}, PREFIX );
                }
                return (0xff); # IDs the above.
            }
            else {

                # Fallback to what once used to be the standard.
                %re = ( path => qr|"url":"(.*?)"| );
                if (clive::Util::matchRegExps( \%re, \$tmp, \$content ) == 0 )
                {
                    $$props->video_id( $tmp->{id} );
                    $$props->video_link( PREFIX . $tmp->{path} );
                    return (0);
                }
            }
        }
    }
    return (1);
}

1;

# No one will level on the line.
