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
package clive::Compat;

use warnings;
use strict;

use clive::Error qw(CLIVE_OK CLIVE_READ);
use clive::Util;

# Upgrades clive 2.0/2.1 config to 2.2+ format.
sub upgradeConfig {
    require File::Spec;
    my $path
        = File::Spec->catfile( $ENV{HOME}, ".config", "clive", "config" );

    require Config::Tiny;
    print("Verify $path.\n");
    my $c = Config::Tiny->read($path);

    if ( !$c ) {
        log->errn( "$path: " . Config::Tiny->errstr );
        exit(CLIVE_READ);
    }

    my %opts = (
        connect_timeout       => $c->{http}->{connect_timeout},
        connect_timeout_socks => $c->{http}->{connect_timeout_socks},
        agent                 => $c->{http}->{agent},
        proxy                 => $c->{http}->{proxy},
        limit_rate            => $c->{http}->{limit_rate},
        format                => $c->{output}->{format},
        save_dir              => $c->{output}->{savedir},
        cclass                => $c->{output}->{cclass},
        format_filename       => $c->{output}->{filename_format},
        format                => $c->{output}->{format},
        cache_dump_format     => $c->{output}->{show},
        exec                  => $c->{commands}->{exec},
        stream_exec           => $c->{commands}->{stream},

        # Obsolete in 2.2:
        #progress => $c->{_}->{progress},
        #ytuser => $c->{youtube}->{user},
        #ytpass => $c->{youtube}->{pass },
        #clivepass => $c->{commands}->{clivepass},
    );

    my $data;
    while ( ( my $i ) = each(%opts) ) {
        $data .= qq/--$i="$opts{$i}"\n/
            if ( $opts{$i} );
    }

    if ( !$data ) {
        my $a = clive::Util::prompt(
            "error: Nothing to upgrade -- View file? (Y/n):");
        system("less $path")
            if ( $a ne "n" );
        exit(CLIVE_OK);
    }

    open my $fh, ">", "$path.new"
        or print( STDERR "error: $path.new: $!" )
        and exit(CLIVE_READ);

    print $fh $data;
    close $fh;

    my $a = clive::Util::prompt("View differences? (Y/n):");
    system("diff -u $path $path.new | less")
        if ( $a ne "n" );

    $a = clive::Util::prompt("Overwrite with new config? (y/N):");
    exit(CLIVE_OK)
        unless ( $a eq "y" );

    print("Backup -> $path.old\n");
    $c->write("$path.old");

    print("Upgrade.\n");
    require File::Copy;
    File::Copy::move( "$path.new", "$path" )
        or print( STDERR "error: move: $!" )
        and exit(CLIVE_READ);
    print("Done.\n");

    exit(CLIVE_OK);
}

1;

# A wildcat did growl.
