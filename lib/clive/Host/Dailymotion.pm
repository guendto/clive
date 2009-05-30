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
package clive::Host::Dailymotion;

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("dailymotion");

    my %re = (
        id    => qr|swf%2F(.*?)"|,
        paths => qr|"video", "(.*?)"|
    );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {

        require URI::Escape;
        my $paths = URI::Escape::uri_unescape( $tmp->{paths} );

        my $config = clive::Config->instance->config;

        my $format = $config->{format};
        $format = "spark" if ( $format eq "flv" );

        my $xurl;
        foreach ( split( /\|\|/, $paths ) ) {
            my ( $path, $type ) = split(/@@/);
            if ( lc($type) eq $format ) {
                $xurl = "http://dailymotion.com$path";
                last;
            }
        }
        if ($xurl) {
            $$props->video_id( $tmp->{id} );
            $$props->video_link($xurl);
            return (0);
        }
        else {
            clive::Log->instance->err( "format unavailable: `$format'", 1 );
        }
    }
    return (1);
}

1;

# Ploughmen dig my earth.
