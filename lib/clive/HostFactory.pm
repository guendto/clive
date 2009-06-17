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
package clive::HostFactory;

use warnings;
use strict;

use clive::Error qw(CLIVE_OK);

my @_hosts = (
    [ "Youtube",     qr|youtube.com|i ],
    [ "Google",      qr|video.google.|i ],
    [ "Sevenload",   qr|sevenload.com|i ],
    [ "Break",       qr|break.com|i ],
    [ "Youtube",     qr|last.fm|i ],
    [ "Liveleak",    qr|liveleak.com|i ],
    [ "Evisor",      qr|evisor.tv|i ],
    [ "Dailymotion", qr|dailymotion.com|i ],
    [ "Cctv",        qr|tv.cctv.com|i ],
    [ "Redtube",     qr|redtube.com|i ],
    [ "Vimeo",       qr|vimeo.com|i ],
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
        my ( $host, $re ) = @{$_};
        print "$1\n"
            if ($re =~ /xsm:(.*?)\)/);
    }
    exit(CLIVE_OK);
}

1;

# Well, you wonder why I always dress in black.
