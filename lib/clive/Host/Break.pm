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
package clive::Host::Break;

# Rewritten: Toni Gundogdu (clive 2.x, Perl).
# Original: Jan Hulsbergen <afoo@gmail.com> (clive 1.x, Python)

use warnings;
use strict;

sub new {
    return bless( {}, shift );
}

sub parsePage {
    my ( $self, $content, $props ) = @_;

    $$props->video_host("break");

    my %re = (
        id    => qr|ContentID='(.*?)'|,
        fpath => qr|ContentFilePath='(.*?)'|,
        fname => qr|FileName='(.*?)'|
    );

    my $tmp;
    if ( clive::Util::matchRegExps( \%re, \$tmp, $content ) == 0 ) {

        my $xurl = "http://media1.break.com/dnet/media"
            . "/$tmp->{fpath}/$tmp->{fname}.flv";

        $$props->video_id( $tmp->{id} );
        $$props->video_link($xurl);

        return (0);
    }
    return (1);
}

1;

# I can't get no relief.
