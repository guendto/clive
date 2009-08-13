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
package clive::Host::Clipfish;

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("clipfish");

    my %re = ( id => qr|/video/(.*?)/| );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, \$$props->page_link ) == 0 )
    {
        my $url
            = "http://www.clipfish.de/video_n.php?p=0|DE&vid=" . $tmp->{id};

        if ( _fetchConfig( $self, $url ) == 0 ) {

            $$props->video_id( $tmp->{id} );
            $$props->video_link( $self->{video_link} );

            return (0);
        }
    }
    return (1);
}

sub _fetchConfig {
    my ( $self, $url ) = @_;

    my $curl = clive::Curl->instance;

    my $content;
    if ( $curl->fetchToMem( $url, \$content, "config" ) == 0 ) {

        my %re = ( xurl => qr|\&url=(.*?)\&| );

        my $tmp;
        if ( clive::Util::matchRegExps( \%re, \$tmp, \$content ) == 0 ) {

            $self->{video_link} = $tmp->{xurl};

            return (0);
        }
    }
    return (1);
}

1;
