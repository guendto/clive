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
package clive::Exec;

use warnings;
use strict;

use base 'Class::Singleton';

sub init {
    my $self = shift;
    $self->{exec_queue}  = [];
    $self->{stream_flag} = 0;
    $self->{stream_pid}  = -1;

    my $config = clive::Config->instance->config;
    if ( $config->{exec} ) {
        if ( $config->{exec} !~ /[;+]$/ ) {
            clive::Log->instance->err( "--exec expression must be "
                    . "terminated by either ';' or '+'" );
            exit(1);
        }
    }
}

sub queue {
    my $self = shift;
    if (@_) {
        my $config = clive::Config->instance->config;
        if ( $config->{exec} ) {
            my $props = shift;
            push( @{ $self->{exec_queue} }, $$props->filename );
        }
    }
    return $self->{exec_queue};
}

sub runExec {
    my $config = clive::Config->instance->config;
    return if !$config->{exec};

    my $self = shift;
    if ( $config->{exec} =~ /;$/ ) {    # Semi
        foreach ( @{ $self->{exec_queue} } ) {
            my $cmd = $config->{exec};
            $cmd =~ s/%i/"$_"/g;
            $cmd =~ tr{;}//d;
            system("$cmd");
        }
    }
    else {                     # Plus
        my $cmd = sprintf( "%s ", $config->{exec} );
        $cmd =~ s/%i//g;
        $cmd =~ tr{+}//d;
        $cmd .= sprintf( '"%s" ', $_ ) foreach ( @{ $self->{exec_queue} } );
        system("$cmd");
    }
}

sub resetStream {
    my $self = shift;

    waitpid( $self->{stream_pid}, 0 )
        if $self->{stream_flag};

    $self->{stream_flag} = 0;
    $self->{stream_pid}  = -1;
}

sub runStream {
    my ( $self, $percent, $props ) = @_;
    my $config = clive::Config->instance->config;
    if (   $config->{stream}
        && $config->{stream_exec}
        && !$self->{stream_flag} )
    {
        _forkStreamer( $self, \$config, $props )
            if ( $percent >= $config->{stream} );
    }
}

sub _forkStreamer {
    my ( $self, $config, $props ) = @_;

    $self->{stream_flag} = 1;
    my $child = fork;
    if ( $child < 0 ) {
        clive::Log->instance->errn("fork: $!");
    }
    elsif ( $child == 0 ) {
        my $cmd   = $$config->{stream_exec};
        my $fname = $$props->filename;
        $cmd =~ s/%i/"$fname"/g;
        system("$cmd");
        exit(0);
    }
}

1;

# Said a joker to the thief.
