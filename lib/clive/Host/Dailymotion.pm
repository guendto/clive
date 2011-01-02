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

sub new { return bless ({}, shift); }

sub parsePage {

    my ($self, $content, $props) = @_;

    $$props->video_host("dailymotion");

    if ($$content =~ /SWFObject\("http:/) {

        clive::Log->instance->err(CLIVE_NOSUPPORT,
            "Looks like a partner video. Refusing to continue.");

        return 1;
    }

    # Match video ID, title.

    my %re = (
        id    => qr|video/(.*?)_|,
        title => qr|title="(.*?)"|,
    );

    my ($tmp, $lnk);

    return 1  if clive::Util::matchRegExps (\%re, \$tmp, $content) != 0;

    # Some videos have only one link available.

    if ($$content =~ /"video", "(.*?)"/)
        { $lnk = $1; }

    else {
        my $r;
        ($r,$lnk) = parseVideoURL ($self, $content);
        return $r  unless $r == 0;
    }

    if (not defined $lnk) {
        clive::Log->instance->err (CLIVE_REGEXP, "no match: video URL");
        return 1;
    }

    # Cleanup video link.

    $lnk =~ s/%5C//g;

    require URI::Escape;
    $lnk = URI::Escape::uri_unescape ($lnk);

    # Set video properties.

    $$props->video_id   ($tmp->{id});
    $$props->page_title (undef, $tmp->{title});
    $$props->video_link ($lnk);

    return 0;
}

sub parseVideoURL {

    my ($self, $content) = @_;
    my $lnk;

    # Match available formats.

    my $re = qr|%22(\w\w)URL%22%3A%22(.*?)%22|;
    my %lst = $$content =~ /$re/gm;

    if (keys %lst == 0) {
        clive::Log->instance->err(CLIVE_REGEXP, "no match: `$re'");
        return (1, $lnk);
    }

    # User requested format.

    my $format = clive::Config->instance->config->{format};
    $format    = "sd" if $format eq "default"; # sd=default

    # Match requested format to a video link.

    foreach (qw/sd hq hd/) {

        if (not exists $lst{$_}) {
            print STDERR "warning: `$_' not found in hash, ignored.\n";
            next;
        }

        if ($format eq "best")
            { $lnk = $lst{$_}; }

        elsif ($format eq $_) {
            $lnk = $lst{$_};
            last;
        }

    }

    # parsePage will take care of checking $lnk value.

    return (0, $lnk);
}

1;

# Nobody of it is worth.
