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
package clive::Log;

use warnings;
use strict;

use base 'Class::Singleton';

use clive::Error qw(CLIVE_OK);

sub init {
    my $self = shift;

    $self->{return_code} = CLIVE_OK;

    my $config = clive::Config->instance->config;
    $self->{quiet} = $config->{quiet};

    # Go unbuffered.
    select STDERR;
    $| = 1;
    select STDOUT;
    $| = 1;
}

sub out {
    my $self = shift;
    return if $self->{quiet};

    my $ref
        = clive::Config->instance->config->{stderr}
        ? \*STDERR
        : \*STDOUT;

    my $fmt = shift;
    my $str = @_ ? sprintf( $fmt, @_ ) : $fmt;

    print $ref $str;
}

sub err {
    my $self = shift;
    $self->{return_code} = shift;

    return if $self->{quiet};

    my $fmt = shift;
    my $msg = "error: " . ( @_ ? sprintf( $fmt, @_ ) : $fmt );

    print( STDERR "$msg\n" );
}

sub errn {
    my $self = shift;

    print( STDERR "\n" )
        if ( !$self->{quiet} );

        err ( $self, @_ );
}

sub returnCode {
    my $self = shift;
    return $self->{return_code};
}

1;

# Why you never see bright colors on my back.
