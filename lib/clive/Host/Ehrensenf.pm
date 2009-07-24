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
package clive::Host::Ehrensenf;

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("ehrensenf");

    my %re = ( data => qr|<h2 class="gradient">(.*?)</h2>| );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {
        if ( $tmp->{data} =~ /(\d\d).(\d\d).(\d\d\d\d)/ ) {
            my $id = "$3-$2-$1";

            my $xurl = "http://www.ehrensenf.de/misc/load-balancing/lb.php?"
                . "file=$id.flv";

            $$props->video_id($id);
            $$props->video_link($xurl);

            return (0);
        }
        else {
            clive::Log->instance->errn("could not match date string");
        }
    }
    return (1);
}

1;
