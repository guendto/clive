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
package clive::Host::Vimeo;

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("vimeo");

    my %re = (
        id    => qr|clip_id=(.*?)"|,
        title => qr|name="title" content="(.*?)"|
    );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {
        my $config = "http://vimeo.com/moogaloop/load/clip:$tmp->{id}";

        if ( _parseConfig( $self, $config, $tmp->{id} ) == 0 ) {
            $$props->video_id( $tmp->{id} );
            $$props->video_link( $self->{video_link} );

            # Less hassle than using <title>.
            $$props->page_title( undef, $tmp->{title} );

            return (0);
        }
    }
    return (1);
}

sub _parseConfig {
    my ( $self, $url, $id ) = @_;

    my $curl = clive::Curl->instance;

    my $content;
    if ( $curl->fetchToMem( $url, \$content, "config" ) == 0 ) {
        my %re = (
            sig => qr|<request_signature>(.*?)</request_signature>|,
            sig_exp =>
                qr|request_signature_expires>(.*?)</request_signature_expires>|
        );

        my $tmp;
        if ( clive::Util::matchRegExps( \%re, \$tmp, \$content ) == 0 ) {
            my $xurl = "http://vimeo.com/moogaloop/play/clip:$id"
                . "/$tmp->{sig}/$tmp->{sig_exp}";
            my $config = clive::Config->instance->config;
            if (   $config->{format} eq "hd"
                || $config->{format} eq "best" )
            {
                my $hd_avail = $1
                    if ( $content =~ /<hd_button>(.*?)<\/hd_button>/ );
                $xurl .= "/?q=hd"
                    if ( $hd_avail && $hd_avail eq "1" );
            }
            $self->{video_link} = $xurl;
            return (0);
        }
    }
    return (1);
}

1;

# So let us not talk falsely now.
