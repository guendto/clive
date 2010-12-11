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
package clive::HostFactory;

use warnings;
use strict;

use clive::Error qw(CLIVE_OK);

my @_hosts = (
    [ "Youtube", qr|youtube.com|i,
# Sat Dec 11 2010: webm_*, 3gp_144p support found in Youtube.pm, website
# no longer seems to list them, however. Listing here only those formats
# that seem to still work.
"default|flv_240p|flv_360p|flv_480p|mp4_360p|mp4_720p|mp4_1080p|mp4_3072p"],
    [ "Youtube",     qr|last.fm|i,         "see youtube formats" ],
    [ "Google",      qr|video.google.|i,   "default|mp4" ],
    [ "Sevenload",   qr|sevenload.com|i,   "default" ],
    [ "Break",       qr|break.com|i,       "default" ],
    [ "Liveleak",    qr|liveleak.com|i,    "default" ],
    [ "Gaskrank",      qr|gaskrank.tv|i,       "default" ],
    [ "Dailymotion", qr|dailymotion.com|i, "default|hq|hd" ],
    [ "Vimeo",       qr|vimeo.com|i,       "default|hd" ],
    [   "Spiegel", qr|spiegel.de|i, "default|vp6_928|vp6_576|vp6_64|h264_1400"
    ],
    [ "Golem",     qr|golem.de|i,      "default|ipod|high" ],
    [ "Clipfish",  qr|clipfish.de|i,   "default" ],
    [ "Funnyhub",  qr|funnyhub.com|i,  "default" ],
    [ "Buzzhumor", qr|buzzhumor.com|i, "default" ],
);

sub new {
    my ( $class, $url ) = @_;
    foreach (@_hosts) {
        my ( $host, $re ) = @{$_};
        if ( $url =~ /$re/ ) {
            my $req = "clive/Host/$host.pm";
            $class = "clive::Host::$host";
            require $req;
            return $class->new(@_);
        }
    }
}

sub dumpHosts {
    my $self = shift;
    foreach (@_hosts) {
        my ( $host, $re, $fmts ) = @{$_};
        printf( "%s\t%s\n", $1, $fmts )
            if ( $re =~ /xsm:(.*?)\)/ && $re !~ /last\.fm/ );
    }
    exit(CLIVE_OK);
}

1;

# The hour's getting late.
