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

use clive::Error qw(CLIVE_FORMAT);

# ON2-1280x720 (vp6-hd)
# ON2-848x480  (vp6-hq)
# H264-512x384 (h264)
# ON2-320x240  (vp6)
# FLV-320x240  (spark)
# FLV-80x60    (spak-mini)

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("dailymotion");

    my %re = (
        id    => qr|swf/(.*?)\?|,
        paths => qr|"video", "(.*?)"|
    );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {

        require URI::Escape;
        my $paths  = URI::Escape::uri_unescape( $tmp->{paths} );
        my $config = clive::Config->instance->config;

        my $format = $config->{format};
        $format = "spark" if ( $format eq "flv" );

        my %width;
        my $xurl = "http://dailymotion.com";

        foreach ( split( /\|\|/, $paths ) ) {
            my ( $path, $type ) = split(/@@/);

            $width{$2} = $path
                if ( $path =~ /cdn\/(.*)-(.*?)x/ );

            if ( lc($type) eq $format
                && $format ne "best" )
            {
                $xurl .= $path;
                last;
            }
        }

        if ( $format eq "best" ) {

            # Sort by width to descending order, assume [0] to be the best.
            my $best = ( sort { $b <=> $a } keys %width )[0];
            $xurl .= $width{$best};
        }

        if ($xurl) {
            $$props->video_id( $tmp->{id} );
            $$props->video_link($xurl);
            return (0);
        }
        else {
            clive::Log->instance->err( CLIVE_FORMAT,
                "format unavailable: `$format'" );
        }
    }
    return (1);
}

1;

# Ploughmen dig my earth.
