# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
#
# Copyright 2009,2010 Toni Gundogdu.
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

use clive::Error qw(CLIVE_FORMAT CLIVE_REGEXP CLIVE_NOSUPPORT);

sub new {
    return bless( {}, shift );
}

use constant LONG_ASS_ERRMSG =>
    "looks like one of dailymotion's partner videos. we cannot currently
error: download any of those videos. note that those videos are often
error: protected by flash drm zealots, so don't ask unless you are
error: volunteering to write a patch.";

sub parsePage {
    my ( $self, $content, $props ) = @_;

    # Can we even dl this video?

    if ( $$content =~ /SWFObject\("http:/ ) {
        clive::Log->instance->err( CLIVE_NOSUPPORT, LONG_ASS_ERRMSG );
        return 1;
    }

    $$props->video_host("dailymotion");

    # Match video ID, title.

    my %re = (
        id    => qr|video/(.*?)_|,
        title => qr|title="(.*?)"|,
    );

    my $tmp;
    return 1
        if clive::Util::matchRegExps( \%re, \$tmp, $content ) != 0;

    # Match available formats.

    my $re = qr|%22(\w\w)URL%22%3A%22(.*?)%22|;
    my %lst = $$content =~ /$re/gm;

    if ( keys %lst == 0 ) {
        clive::Log->instance->err( CLIVE_REGEXP, "no match: `$re'" );
        return 1;
    }

    # User requested format.

    my $format = clive::Config->instance->config->{format};
    $format = "sd" if $format eq "flv";    # Alias.

    # Match requested format to a video link.

    my $lnk;
    foreach (qw/sd hq hd/) {
        if ( not exists $lst{$_} ) {
            print STDERR "warning: `$_' not found in hash, ignored.\n";
            next;
        }
        if ( $format eq "best" ) {
            $lnk = $lst{$_};
        }
        elsif ( $format eq $_ ) {
            $lnk = $lst{$_};
            last;
        }
    }

    if ( not defined $lnk ) {
        clive::Log->instance->err( CLIVE_REGEXP,
            "oops. \$lnk undefined. that does not look right. terminating." );
        return 1;
    }

    # Cleanup video link.

    $lnk =~ s/%5C//g;
    require URI::Escape;
    $lnk = URI::Escape::uri_unescape($lnk);

    # Set video properties.

    $$props->video_id( $tmp->{id} );
    $$props->page_title( undef, $tmp->{title} );
    $$props->video_link($lnk);

    return 0;
}

1;

# Nobody of it is worth.
