# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
#
# Copyright 2009,2010 Toni Gundogdu.
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

sub new { return bless ({}, shift); }

sub parsePage {
    my ($self, $content, $props) = @_;

    $$props->video_host ("youtube");

    my %re = (
        id => qr|"video_id": "(.*?)"|,
        fmt_url_map => qr|fmt_url_map=(.*?)&|,
    );

    my $tmp;
    if (clive::Util::matchRegExps (\%re, \$tmp, $content) == 0) {

        my $best;
        my %h;

        require URI::Escape;

        foreach (split /,/, URI::Escape::uri_unescape ($tmp->{fmt_url_map})) {
            my ($id, $url) = split /\|/, $_;
            $best   = $url unless $best;
            $h{$id} = $url;
        }

        my $url;

        my $config = clive::Config->instance->config;

        if ($config->{format} eq 'best') {
            $url = $best;
        }
        else {
            $url = toURL ($self, $config->{format}, \%h);
            $url = toURL ($self, 'default', \%h)  unless $url;
        }

        $$props->video_id ($tmp->{id});
        $$props->video_link ($url);

        return 0;
    }

    return 1;
}

sub toURL {
    my ($self, $fmt, $h) = @_;

    $fmt = 'flv_240p'  if $fmt eq 'default';
    $fmt = toFmt ($self, $fmt);

    foreach (keys %{$h})
        { return $$h{$_}  if $_ eq $fmt; }

    return undef;
}

sub toFmt {
    my ($self, $id) = @_;

# http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
# $container_$maxwidth = '$fmt_id'

    my %h = (
        # flv
        flv_240p => '5',
        flv_360p => '34',
        flv_480p => '35',
        # mp4
        mp4_360p  => '18',
        mp4_720p  => '22',
        mp4_1080p => '37',
        mp4_3072p => '38',
        # webm
        webm_480p => '43',
        webm_720p => '45',
        # 3gp
        '3gp_144p'=> '17',

# For backward-compatibility only.
        mobile    => '17',
        sd_270p   => "18",
        sd_360p   => "34",
        hq_480p   => "35",
        hd_720p   => "22",
        hd_1080p  => "37",
        webm_480p => "43",
        webm_720p => "45",
        '3gp' => "17",
        mp4   => "18",
        hq    => "35",
        hd    => "22",
    );

    foreach (keys %h)
        { return $h{$_}  if $id eq $_; }

    return $id;
}

1;

# And this is not our fate.
