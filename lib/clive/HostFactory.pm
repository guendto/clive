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
    [ "Youtube",   qr|youtube.com|i,   "flv|3gp|mp4|hq|hd" ],
    [ "Youtube",   qr|last.fm|i,       "see above" ],
    [ "Google",    qr|video.google.|i, "flv|mp4" ],
    [ "Sevenload", qr|sevenload.com|i, "flv" ],
    [ "Break",     qr|break.com|i,     "flv" ],
    [ "Liveleak",  qr|liveleak.com|i,  "flv" ],
    [ "Evisor",    qr|evisor.tv|i,     "flv" ],
    [   "Dailymotion", qr|dailymotion.com|i,
        "flv|spark-mini|vp6-hq|vp6-hd|vp6|h264"
    ],
    [ "Cctv",    qr|tv.cctv.com|i, "flv" ],
    [ "Redtube", qr|redtube.com|i, "flv" ],
    [ "Vimeo",   qr|vimeo.com|i,   "flv|hd" ],
    [ "Spiegel", qr|spiegel.de|i,  "flv|vp6_928|vp6_576|vp6_64|h264_1400" ],
    [ "Golem",   qr|golem.de|i,    "flv|ipod|high" ],
    [ "Ehrensenf", qr|ehrensenf.de|i, "flv" ],
    [ "Clipfish",  qr|clipfish.de|i,  "flv" ],
    [ "Funnyhub",  qr|funnyhub.com|i, "flv" ],
    [ "Myubo",  qr|myubo.com|i, "flv" ],
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
    print
        "\nNote: Some videos may have limited number of formats available.\n";
    exit(CLIVE_OK);
}

1;

# The hour's getting late.
