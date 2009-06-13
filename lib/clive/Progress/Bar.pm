# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
# Copyright 2007, 2008, 2009 Toni Gundogdu.
# Copyright (C) 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008
#   Free Software Foundation, Inc.
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
package clive::Progress::Bar;

use warnings;
use strict;

use File::Basename qw(basename);

use clive::Util;

use constant DEFAULT_TERM_WIDTH => 80;
use constant REFRESH_INTERVAL   => 0.2;

my $recv_sigwinch;

sub new {
    my ( $class, $props ) = @_;

    my $initial = $$props->initial_length;
    my $total   = $$props->file_length;

    $total = $initial
        if ( $initial > $total );

    $recv_sigwinch = 0;
    $SIG{WINCH} = \&handle_sigwinch;

    my $self = {
        props        => $$props,
        initial      => $initial,
        total        => $total,
        term_width   => clive::Util::termWidth(),
        width        => DEFAULT_TERM_WIDTH - 1,
        last_update  => 0,
        done         => 0,
        time_started => time,
    };

    return bless( $self, $class );
}

sub update {
    my ( $self, $clientp, $total, $now, $ultotal, $ulnow ) = @_;

    my $force_update = 0;
    if ($recv_sigwinch) {
        my $old_width = $self->{term_width};
        $self->{term_width} = clive::Util::termWidth();
        if ( $self->{term_width} != $old_width ) {
            $self->{width} = $self->{term_width} - 1;
            $force_update = 1;
        }
        $recv_sigwinch = 0;
    }

    my $tnow    = time;
    my $elapsed = $tnow - $self->{time_started};

    if ( !$self->{done} ) {
        if ( ( $elapsed - $self->{last_update} ) < REFRESH_INTERVAL
            && !$force_update )
        {
            return ( 0, 0 );
        }
    }
    else {
        $now = $self->{total};
    }

    $self->{last_update} = $elapsed;
    my $size = $self->{initial} + $now;

    my $fname_len = 32;
    if ( $self->{width} > DEFAULT_TERM_WIDTH ) {
        $fname_len += $self->{width} - DEFAULT_TERM_WIDTH;
    }

    my $buf = substr( basename( $self->{props}->filename ), 0, $fname_len );

    my $percent       = 0;
    my $stop_transfer = 0;

    if ( $self->{total} > 0 ) {
        my $_size = !$self->{done} ? $size : $now;
        $percent = 100.0 * $size / $self->{total};
        if ( $percent < 100 ) {
            $buf .= sprintf( "  %2d%% ", $percent );
        }
        else {
            $buf .= sprintf("  100%%");
        }
        $buf .= sprintf(
            "  %4.1fM / %4.1fM",
            clive::Util::toMB($_size),
            clive::Util::toMB( $self->{total} )
        );

        my $stop_after = clive::Config->instance->config->{stop_after};
        if ($stop_after) {
            if ( $stop_after =~ /(.*?)M$/ ) {
                $stop_transfer = 1
                    if ( clive::Util::toMB($_size) >= $1 );
            }
            elsif ( $stop_after =~ /(.*?)%$/ ) {
                $stop_transfer = 1
                    if ( $percent >= $1 );
            }
        }
    }

    my $rate = $elapsed ? ( $now / $elapsed ) : 0;
    my $tmp = "";
    if ( $rate > 0 ) {
        my $eta;
        if ( !$self->{done} ) {
            my $left = ( $total - $now ) / $rate;
            $eta = clive::Util::timeToStr($left);
        }
        else {
            $eta = clive::Util::timeToStr($elapsed);
        }
        my ( $unit, $_rate ) = clive::Util::toUnits($rate);
        $tmp = sprintf( "  %4.1f%s  %6s", $_rate, $unit, $eta );
    }
    else {
        $tmp = "  --.-K/s  --:--";
    }

    # pad to max. width leaving enough space for rate+eta
    my $pad = $self->{width} - length($tmp) - length($buf);
    $buf .= sprintf( "%${pad}s", " " );
    $buf .= $tmp;              # append rate+eta

    clive::Log->instance->out("\r$buf");
    $self->{count} = $now;

    return ( $percent, $stop_transfer, \$self->{props} );
}

sub finish {
    my $self = shift;
    if (   $self->{total} > 0
        && $self->{count} + $self->{initial} > $self->{total} )
    {
        $self->{total} = $self->{initial} + $self->{count};
    }

    $self->{done} = 1;
    update( $self, -1, -1, -1, -1, -1 );
}

sub handle_sigwinch {
    $recv_sigwinch = 1;
}

1;

# With time to kill.
