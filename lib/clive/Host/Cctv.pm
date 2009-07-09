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
package clive::Host::Cctv;

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("cctv");

    my %re = ( id => qr|videoId=(.*?)&| );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {
        my $domain = join( '.', clive::Util::toDomain( $$props->page_link ) );
        my $config
            = "http://$domain/playcfg/flv_info_new.jsp?videoId=$tmp->{id}";

        my $curl = clive::Curl->instance;

        my $content;
        if ( $curl->fetchToMem( $config, \$content, "config" ) == 0 ) {
            %re = ( path => qr|"url":"(.*?)"| );
            if ( clive::Util::matchRegExps( \%re, \$tmp, \$content ) == 0 ) {
                $$props->video_id( $tmp->{id} );
                $$props->video_link("http://v.cctv.com/flash/$tmp->{path}");
                return (0);
            }
        }
    }
    return (1);
}

1;

# No one will level on the line.
