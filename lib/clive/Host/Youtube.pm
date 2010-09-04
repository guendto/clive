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

# List of format IDs. This info is based on <http://quvi.googlecode.com/>.
# Old clive aliases, for backward-compatibility, in parenthesis.
# mobile   = 17 --       3gp (fmt17, 3gp)
# sd_270p  = 18 --   480x270 (fmt18, mp4)
# sd_360p  = 34 --   640x360 (fmt34)
# hq_480p  = 35 --   848x480 (fmt35, hq)
# hd_720p  = 22 --  1280x720 (fmt22, hd)
# hd_1080p = 37 -- 1920x1080 (added in 2.2.15)
# Default is whatever Youtube gives us without the &fmt param.

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("youtube");

    my %re = (
        id => qr|&video_id=(.*?)&|,
        t  => qr|&t=(.*?)&|,
    );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {

        require URI::Escape;

        $tmp->{t} = URI::Escape::uri_unescape( $tmp->{t} );

        my $xurl
            = "http://youtube.com/get_video?video_id=$tmp->{id}&t=$tmp->{t}";

        $xurl .= "&asv=2";     # Should fix the http/404 issue (#58).

        my $config = clive::Config->instance->config;

        my $fmt;

        if ( $config->{format} eq "best" ) {
            $fmt = $1
                if ( $$content =~ /&fmt_map=(\d+)/ && $1 ne "" );
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

    my %h = (
        mobile   => "fmt17",
        sd_270p  => "fmt18",
        sd_360p  => "fmt34",
        hq_480p  => "fmt35",
        hd_720p  => "fmt22",
        hd_1080p => "fmt37",

        # For backward-compatibility only.
        '3gp' => "fmt17",
        mp4   => "fmt18",
        hq    => "fmt35",
        hd    => "fmt22",
    );

    $id =~ s/$_/$h{$_}/ foreach keys %h;

    return ($id);
}

1;

# And this is not our fate.
