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
package clive::Host::Youtube;

use warnings;
use strict;

# fmt22 = HD    [1280x720]
# fmt35 = HQ     [640x380]
# fmt17 = 3gp    [176x144]
# fmt18 = mp4    [480x360]
# fmt34 = flv    [320x180] (quality reportedly varies)

# If --format is unused, clive defaults to whatever youtube
# defaults to: we do not append the "&fmt=" to the video link.

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("youtube");

    my %re = (
        id => qr|"video_id": "(.*?)"|,
        t  => qr|"t": "(.*?)"|,
    );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {

        my $xurl
            = "http://youtube.com/get_video?video_id=$tmp->{id}&t=$tmp->{t}";

        my $config = clive::Config->instance->config;

        my $fmt;

        if ( $config->{format} eq "best" ) {
            $fmt = $1
                if ( $$content =~ /"fmt_map": "(.*?)(?:%2F|\/|")/
                && $1 ne "" );
        }
        else {
            $fmt = $1
                if toFmt( $self, $config->{format} ) =~ /^fmt(.*)$/;
        }

        $xurl .= "&fmt=$fmt"
            if $fmt;

        $$props->video_id( $tmp->{id} );
        $$props->video_link($xurl);

        return (0);
    }
    return (1);
}

sub toFmt {
    my ( $self, $id ) = @_;
    $id =~ s/hd/fmt22/;
    $id =~ s/hq/fmt35/;
    $id =~ s/mp4/fmt18/;
#    $id =~ s/fmt34/flv/; # Previously assumed to be the "youtube default format"
    $id =~ s/3gp/fmt17/;
    return ($id);
}

1;

# And this is not our fate.
