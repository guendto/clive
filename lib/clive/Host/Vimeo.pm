# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
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
package clive::Host::Vimeo;

use warnings;
use strict;

use clive::Error qw(CLIVE_REGEXP);

sub new { return bless ({}, shift); }

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("vimeo");

    my $id = $1  if $$props->page_link =~ /vimeo\.com\/(\d+)/;

    unless ($1) {
        clive::Log->instance->err (CLIVE_REGEXP, "no match: video id");
        return (1);
    }

    my $config_url = "http://vimeo.com/moogaloop/load/clip:$1";
    my $rc         = _parseConfig ($self, $config_url, $1);

    unless ($rc) {
        $$props->video_id ($id);
        $$props->video_link ($self->{video_link});
    }

    return ($rc);
}

sub _parseConfig {
    my ( $self, $url, $id ) = @_;

    my $curl = clive::Curl->instance;

    my $content;
    if ( $curl->fetchToMem( $url, \$content, "config" ) == 0 ) {

        if ($content =~ /<error>/) {
            my $e = "no match: error message";
            $e = $1 if $content =~ /<message>(.*?)\n/;
            clive::Log->instance->err (CLIVE_REGEXP, $e);
            return 1;
        }

        my %re = (
            sig => qr|<request_signature>(.*?)</request_signature>|,
            sig_exp =>
                qr|request_signature_expires>(.*?)</request_signature_expires>|
        );

        my $tmp;
        if ( clive::Util::matchRegExps( \%re, \$tmp, \$content ) == 0 ) {
            my $xurl = "http://vimeo.com/moogaloop/play/clip:$id"
                . "/$tmp->{sig}/$tmp->{sig_exp}/?q=";
            my $config = clive::Config->instance->config;
            my $q      = "sd";
            if (   $config->{format} eq "hd"
                || $config->{format} eq "best" )
            {
                if ( $content =~ /<hd_button>(.*?)<\/hd_button>/ ) {
                    $q = "hd" if ( $1 eq "1" );
                }
            }
            $xurl .= $q;
            $self->{video_link} = $xurl;
            return (0);
        }
    }
    return (1);
}

1;

# So let us not talk falsely now.
