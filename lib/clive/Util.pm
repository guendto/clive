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
package clive::Util;

use warnings;
use strict;

eval("use Term::ReadKey");
my $TermReadKey = int( !$@ );

use clive::Error qw(CLIVE_REGEXP);

use constant DEFAULT_TERM_WIDTH => 80;
use constant MBDIV              => 0x100000;

sub termWidth {
    return DEFAULT_TERM_WIDTH
        unless $TermReadKey;
    my ($width) = Term::ReadKey::GetTerminalSize();
    return $width;
}

sub toMB {
    my $bytes = shift;
    return $bytes / MBDIV;
}

sub fileExists {
    my ($path) = @_;
    return -s $path || 0;
}

sub timeToStr {
    my $secs = shift;

    my $str;
    if ( $secs < 100 ) {
        $str = sprintf( "%ds", $secs );
    }
    elsif ( $secs < 100 * 60 ) {
        $str = sprintf( "%dm%ds", $secs / 60, $secs % 60 );
    }
    elsif ( $secs < 48 * 3600 ) {
        $str = sprintf( "%dh%dm", $secs / 3600, ( $secs / 60 ) % 60 );
    }
    elsif ( $secs < 100 * 86400 ) {
        $str = sprintf( "%dd%dh", $secs / 86400, ( $secs / 3600 ) % 60 );
    }
    else {
        $str = sprintf( "%dd", $secs / 86400 );
    }
    return $str;
}

sub toUnits {
    my $rate = shift;

    my @units = qw|K/s M/s G/s|;

    my $i = 0;
    if ( $rate < 1024 * 1024 ) {
        $rate /= 1024;
    }
    elsif ( $rate < 1024 * 1024 ) {
        $rate /= 1024 * 1024;
        $i = 1;
    }
    elsif ( $rate < 1024 * 1024 * 1024 ) {
        $rate /= 1024 * 1024 * 1024;
        $i = 2;
    }
    return ( $units[$i], $rate );
}

sub matchRegExps {
    my ( $regexps, $results, $content ) = @_;
    while ( my ( $key, $re ) = each( %{$regexps} ) ) {
        $$results->{$key} = $1 if $$content =~ /$re/;
        if ( !$$results->{$key} ) {
            clive::Log->instance->err( CLIVE_REGEXP, "no match: `$re'" );
            return (1);
        }
    }
    return (0);
}

sub toDomain {
    my $uri = shift;

    my ( $scheme, $authority, $path, $query, $fragment )
        = $uri
        =~ m{(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?}o;

    return split( /\./, $authority );
}

sub prompt {
    print shift;
    chomp( my $ln = <STDIN> );
    return $ln;
}

1;

# While all the women came and went.
