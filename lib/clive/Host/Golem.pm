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
package clive::Host::Golem;

use warnings;
use strict;

# --format=(high|medium|ipod)
# high   = hd
# medium = default (what we call "flv" in clive)
# ipod   = ipod

# Note that we do not use "medium" at all. The host
# defaults to "medium" if "?q=" is not appended.
# Users do not need to bother themselves with this.

# We use config:title instead of video page title
# if it can be parsed from the config. Saves us
# the trouble from cleaning up the <title>.

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("golem");

    my %re = ( id => qr|"id", "(.*?)"| );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {
        my $url = "http://video.golem.de/xml/$tmp->{id}";
        if ( _fetchConfig( $self, $url, $tmp->{id} ) == 0 ) {

            $$props->page_title( undef, $self->{page_title} )
                if ( $self->{page_title} );

            $$props->video_id( $tmp->{id} );
            $$props->video_link( $self->{video_link} );

            return (0);
        }
    }
    return (1);
}

sub _fetchConfig {
    my ( $self, $url, $id ) = @_;

    my $curl = clive::Curl->instance;

    my $content;
    if ( $curl->fetchToMem( $url, \$content, "config" ) == 0 ) {

        my $xurl   = "http://video.golem.de/download/$id";
        my $config = clive::Config->instance->config;

        my $title = $1
            if ( $content =~ /<title>(.*?)<\/title>/ );

        my $fmt;
        if ( $config->{format} eq "best" ) {

            my %re = ( path => qr|<filename>(.*?)</filename>| );
            my @fnames = $content =~ /$re{path}/g;

            foreach my $i (qw/hd sd ipod/) {
                if ( my @b = grep( /$i/, @fnames ) ) {
                    $fmt = $b[0];
                    last;
                }
            }

            $fmt =~ s/hd/high/;
            $fmt =~ s/sd//;    # medium
        }
        else {
            $fmt = $config->{format};
            $fmt =~ s/flv//;   # medium (default)
        }

        $xurl .= "?q=$fmt"
            if $fmt;

        $self->{page_title} = $title;
        $self->{video_link} = $xurl;

        return (0)
            if $xurl;
    }
    return (1);
}

1;

# And the wind began to howl.
