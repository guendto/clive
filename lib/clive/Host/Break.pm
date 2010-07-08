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
package clive::Host::Break;

# Rewritten from the original code contribution by Jan Hulsbergen
# <afoo@gmail.com> which was written in Python for clive 1.0.

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("break");

    my %re = (
        id    => qr|sGlobalContentID='(.*?)'|,
        fname => qr|sGlobalFileName='(.*?)'|,
        fhash => qr|flashVars.icon = \"(.*?)\"|,
        title => qr|id="vid_title" content="(.*?)"|
    );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {

        my $xurl = "$tmp->{fname}.flv?$tmp->{fhash}";

        $$props->video_id( $tmp->{id} );
        $$props->page_title( undef, $tmp->{title} );
        $$props->video_link($xurl);

        return (0);
    }
    return (1);
}

1;

# Ploughmen dig my earth.
