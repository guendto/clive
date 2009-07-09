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
package clive::Cache;

use warnings;
use strict;

use base 'Class::Singleton';

use clive::Video;
use clive::Error qw(CLIVE_OK CLIVE_GREP);

use constant DEFAULT_DUMP_FORMAT => qq/%n: %t [%f, %mMB]/;

sub init {
    my $self = shift;

    my $config = clive::Config->instance->config;

    $self->{enabled} = 0;

    eval("require BerkeleyDB");
    $self->{enabled} = 1
        if ( !$@ && !$config->{no_cache} );

    if ( $self->{enabled} ) {
        require Digest::SHA;

        my %cache;
        my $handle = tie(
            %cache, "BerkeleyDB::Hash",
            -Filename => $config->{cache_file},
            -Flags    => BerkeleyDB->DB_CREATE
        ) or die "error: cannot open $config->{cache_file}: $!\n";

        $self->{handle} = $handle;
        $self->{cache}  = \%cache;

        if ( $config->{cache_dump} ) {
            _dumpCache($self);
        }
        elsif ( $config->{cache_grep} ) {
            _grepCache($self);
        }
        elsif ( $config->{cache_clear} ) {
            _clearCache($self);
        }
    }
}

sub enabled {
    my $self = shift;
    return $self->{enabled};
}

sub read {
    my $self = shift;
    return (1) if !$self->{enabled};
    return _mapRecord( $self, @_ );
}

sub write {
    my $self = shift;
    return if !$self->{enabled};
    my $props = shift;
    my $hash  = Digest::SHA::sha1_hex( $$props->page_link );
    $self->{cache}{$hash} = $$props->toCacheRecord;
    $self->{handle}->db_sync();
}

sub grepQueue {
    my $self = shift;
    $self->{grep_queue};
}

sub _mapRecord {
    my ( $self, $props, $hash ) = @_;
    $hash = Digest::SHA::sha1_hex( $$props->page_link )
        if ( !$hash );

    # Key order matters. Keep in sync with clive::Video::toCacheRecord order.
    if ( $self->{cache}{$hash} ) {
        my @values = split( /#/, $self->{cache}{$hash} );
        my @keys = qw(
            page_title      page_link      video_id      video_link
            video_host      video_format   file_length   file_suffix
            content_type    time_stamp
        );
        my $i = 0;
        my %record = map { $_ => $values[ $i++ ] } @keys;
        $$props->fromCacheRecord( \%record );
        return (1);
    }
    return (0);
}

sub _dumpCache {
    my $self = shift;

    my $config  = clive::Config->instance->config;
    my $dumpfmt = $config->{cache_dump_format} || DEFAULT_DUMP_FORMAT;
    my $props   = clive::Video->new
        ;                      # Reuse this rather than re-create it for each record.

    my $i = 1;
    print _formatDump( $self, $dumpfmt, $_, \$props, $i++ ) . "\n"
        foreach ( keys %{ $self->{cache} } );

    exit(CLIVE_OK);
}

sub _grepCache {
    my $self = shift;

    my $config  = clive::Config->instance->config;
    my $dumpfmt = $config->{cache_dump_format} || DEFAULT_DUMP_FORMAT;
    my $props   = clive::Video->new
        ;                      # Reuse this rather than re-create it for each record.

    my $g
        = $config->{cache_ignore_case}
        ? qr|$config->{cache_grep}|i
        : qr|$config->{cache_grep}|;

    $self->{grep_queue} = [];
    my $i = 1;
    foreach ( keys %{ $self->{cache} } ) {
        my $dumpstr = _formatDump( $self, $dumpfmt, $_, \$props, $i++ );
        my @e = split( /#/, $self->{cache}{$_} );
        if ( grep /$g/, @e ) {
            push( @{ $self->{grep_queue} }, $props->page_link );
            print "$dumpstr\n"
                if ( $config->{cache_remove_record} );
        }
    }

    if ( $config->{cache_remove_record} ) {
        if ( scalar( @{ $self->{grep_queue} } ) > 0 ) {
            print("Confirm delete (y/N):");
            $_ = lc <STDIN>;
            chomp;
            if ( lc $_ eq "y" ) {
                foreach ( @{ $self->{grep_queue} } ) {
                    my $hash = Digest::SHA::sha1_hex($_);
                    delete $self->{cache}{$hash};
                }
            }
            exit(CLIVE_OK);
        }
    }
    if ( scalar( @{ $self->{grep_queue} } ) == 0 ) {
        clive::Log->instance->err( CLIVE_GREP,
            "nothing matched $g in cache" );
        exit(CLIVE_GREP);
    }
}

sub _formatDump {
    my ( $self, $dumpfmt, $hash, $props, $index ) = @_;

    if ( _mapRecord( $self, $props, $hash ) ) {
        my $title  = $$props->page_title;
        my $id     = $$props->video_id;
        my $host   = $$props->video_host;
        my $len    = $$props->file_length;
        my $mb     = sprintf( "%.1f", clive::Util::toMB($len) );
        my $tstamp = $$props->time_stamp;
        my ( $date, $time ) = ( split( / /, $tstamp ) );
        my $format = $$props->video_format;
        $index = sprintf( "%04d", $index );

        my $fmt = $dumpfmt;
        $fmt =~ s/%t/$title/g;
        $fmt =~ s/%i/$id/g;
        $fmt =~ s/%h/$host/g;
        $fmt =~ s/%l/$len/g;
        $fmt =~ s/%m/$mb/g;
        $fmt =~ s/%d/$date/g;
        $fmt =~ s/%T/$time/g;
        $fmt =~ s/%s/$tstamp/g;
        $fmt =~ s/%f/$format/g;
        $fmt =~ s/%n/$index/g;

        return $fmt;
    }
    return "";
}

sub _clearCache {
    my $self  = shift;
    my $count = 0;
    $self->{handle}->truncate($count);
    print "$count records truncated.\n";
    exit(CLIVE_OK);
}

sub DESTROY {
    my $self = shift;
    $self->{handle} = undef;
    if ( $self->{cache} ) {
        untie( %{ $self->{cache} } );
    }
}

1;

# Said a joker to the thief.
