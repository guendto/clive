# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
#
# Copyright 2009,2010,2011 Toni Gundogdu.
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
package clive::Host::Dailymotion;

use warnings;
use strict;

use clive::Error qw(CLIVE_REGEXP CLIVE_NOSUPPORT);

sub new { return bless( {}, shift ); }

sub parsePage {

    my ( $self, $content, $props ) = @_;

    $$props->video_host("dailymotion");

    my %re = (
        title => qr|title="(.*?)"|,
        id    => qr|video/(.*?)_|
    );

    my $r;
    return 1 if clive::Util::matchRegExps( \%re, \$r, $content ) != 0;

    return 1 if getURL( $self, \$r, $content ) != 0;

    $$props->video_id( $r->{id} );
    $$props->page_title( undef, $r->{title} );
    $$props->video_link( $r->{url} );

    return 0;
}

sub getURL {
    my ( $self, $r, $content ) = @_;

    if ( $$content !~ /"sequence",\s+"(.*?)"/ ) {
        my $e = "no match: sequence";
        if ( $$content =~ /"_partnerplayer"/ ) {
            $e .=
              ": looks like a partner video which we do not support";
        }
        clive::Log->instance->err( CLIVE_REGEXP, $e );
        return 1;
    }

    require URI::Escape;
    my $seq = URI::Escape::uri_unescape($1);

    if ( $seq !~ /"videoPluginParameters":\{(.*?)\}/ ) {
        if ( $$content !~ /"video", "(.*?)"/ ) {
            clive::Util::Log->err( CLIVE_REGEXP,
                "no match: video plugin params" );
            return 1;
        }
        else {

            # Some videos (that require setting family_filter cookie)
            # may list only one link which is not found under
            # "videoPluginParameters". See also:
            # http://sourceforge.net/apps/trac/clive/ticket/4
            $$r->{url} = $1;
            return 0;
        }
    }

    my $vpp = $1;

    # "sd" is our "default".
    my $req_fmt = clive::Config->instance->config->{format};
    $req_fmt = "sd" if $req_fmt eq "default";

    # Choose "best" from the array. Check against the reported video
    # resolution (height). Pick the highest available.
    my ( $best, $curr );
    my $best_h = 0;

    my $re = qr|(\w+)URL":"(.*?)"|;
    my %h = $vpp =~ /$re/gm;

    while ( my ( $id, $url ) = each(%h) ) {
        $url =~ tr{\\}{}d;

        # Found the requested format ID.
        if ( $id eq $req_fmt ) {
            $curr = $url;
            last;
        }

        # Default to whatever is the first in the array.
        $curr ||= $url;

        # Compare height with current (best) height.
        if ( $url =~ /(\d+)x(\d+)/ ) {
            if ( $2 > $best_h ) {
                $best_h = $2;
                $best   = $url;
            }
        }
    }

    # If the user requested "best", set whatever we found as such above.
    $curr = $best if $req_fmt eq "best";

    $$r->{url} = $curr;

    return 0;
}

1;

# Nobody of it is worth.
