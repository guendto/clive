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

# Rewritten from the original code contribution by Kai Wasserbach
# <debian@carbon-project.org> which was written in Python for clive 1.0.

package clive::Host::Sevenload;

use warnings;
use strict;

use clive::Error qw(CLIVE_REGEXP);

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

        my $re = qr|item id="(\w+)">\s+<title>(.*?)</|i;

        if ( $content =~ $re ) {
            my ( $id, $title ) = ( $1, $2 );
            $$props->video_id($id);
            $$props->page_title( undef, $title );
        }
        else {
            clive::Log->instance->err( CLIVE_REGEXP, "no match: `$re'" );
            return (1);
        }

        $re = qr|location seeking="yes">(.*?)</|i;

        if ( $content =~ /$re/ ) {
            my $lnk = $1;
            $lnk =~ s/&amp;/&/g;
            $$props->video_link($lnk);
        }
        else {
            clive::Log->instance->err( CLIVE_REGEXP, "no match: `$re'" );
            return (1);
        }

        return (0);
    }
    return (1);
}

1;

# But ah, you and I we've been through that.
