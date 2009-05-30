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

# Rewritten: Toni Gundogdu (clive 2.x, Perl).
# Original: Kai Wasserbach <debian@carbon-project.org> (clive 1.x, Python)

package clive::Host::Sevenload;

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("sevenload");

    my %re = ( config => qr|configPath=(.*?)"| );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {
        return _parseConfig( $self, $tmp->{config}, $props );
    }
    return (1);
}

sub _parseConfig {
    my ( $self, $url, $props ) = @_;

    require URI::Escape;
    $url = URI::Escape::uri_unescape($url);

    my $curl = clive::Curl->instance;
    my $log  = clive::Log->instance;

    my $content;
    if ( $curl->fetchToMem( $url, \$content, "config" ) == 0 ) {
        my %re = (
            id       => qr|item id="(.*?)"|,
            location => qr|<location seeking="yes">(.*?)</location>|
        );
        my $tmp;
        if ( clive::Util::matchRegExps( \%re, \$tmp, \$content ) == 0 ) {
            $$props->video_id( $tmp->{id} );
            $$props->video_link( $tmp->{location} );
            return (0);
        }
    }
    return (1);
}

1;

# Early one morning.
