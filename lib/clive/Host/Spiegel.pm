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
package clive::Host::Spiegel;

use warnings;
use strict;

# The fetched config xml contains paths to
# 3gp, small, etc. but we are yet to find
# a working link to test them properly.

# h264 and the vp_(*) videos seem to work OK.

use clive::Curl;
use clive::Log;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("spiegel");

    my %re = ( id => qr|/video/video-(.*?)\.| );

    my $id = $1
        if ( $$props->page_link =~ /$re{id}/ );

    my $log = clive::Log->instance;

    if ( !$id ) {
        $log->errn("not matched: `$re{id}'");
        return (1);
    }

    # playlist: get title (html page does not disclose title)
    if ( _fetchPlaylist( $self, $id ) == 0 ) {

        # config: get list of available videos
        if ( _fetchConfig( $self, $id ) == 0 ) {
            $$props->video_id($id);
            $$props->page_title( undef, $self->{title} );
            $$props->video_link( $self->{video_link} );
            return (0);
        }
    }
    return (1);
}

sub _fetchPlaylist {
    my ( $self, $id ) = @_;

    my $url = "http://www1.spiegel.de/active/playlist/fcgi/playlist.fcgi/"
        . "asset=flashvideo/mode=id/id=$id";

    my $curl = clive::Curl->instance;

    my $content;
    if ( $curl->fetchToMem( $url, \$content, "playlist" ) == 0 ) {
        my %re = ( headline => qr|<headline>(.*?)</headline>| );
        my $tmp;
        if ( clive::Util::matchRegExps( \%re, \$tmp, \$content ) == 0 ) {
            $self->{title} = $tmp->{headline};
            return (0);
        }
    }
    return (1);
}

sub _fetchConfig {
    my ( $self, $id ) = @_;

    my $url  = "http://video.spiegel.de/flash/$id.xml";
    my $curl = clive::Curl->instance;

    my $content;
    if ( $curl->fetchToMem( $url, \$content, "config" ) == 0 ) {
        my %re = (
            path => qr|<filename>(.*?)</filename>|,
            rate => qr|_(\d+)\.|
        );

        my @fnames = $content =~ /$re{path}/g;
        my $path = $fnames[0];    # default flv

        my $config = clive::Config->instance->config;

        if ( $config->{format} eq "best" ) {
            my %rates;         # Ignores iphone, 3gp etc.
            foreach (@fnames) {
                $rates{$1} = $_
                    if ( $_ =~ /$re{rate}/ );
            }
            my $best = ( sort { $b <=> $a } keys %rates )[0];
            $path = $rates{$best};
        }
        else {
            if ( my @m = grep( /$config->{format}/i, @fnames ) ) {
                $path = $m[0];
            }
        }
        if ($path) {
            $self->{video_link} = "http://video.spiegel.de/flash/$path";
            return (0);
        }
    }
    return (1);
}

1;

# Two riders were approaching.
