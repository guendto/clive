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
package clive::App;

use warnings;
use strict;

use base 'Class::Singleton';

use clive::Log;
use clive::Error qw(
    CLIVE_OK
    CLIVE_NOTHINGTODO
    CLIVE_NOSUPPORT
    CLIVE_READ
);
use clive::Config;
use clive::Curl;
use clive::Cache;
use clive::Exec;

sub new {
    my $class = shift;
    return bless( {}, $class );
}

sub main {
    my $self = shift;

    clive::Config->instance->init;
    clive::Curl->instance->init;
    clive::Log->instance->init;
    clive::Cache->instance->init;
    clive::Exec->instance->init;

    _parseInput();

    exit( clive::Log->instance->returnCode );
}

sub _parseInput {
    my $self = shift;

    $self->{queue} = [];

    my $config = clive::Config->instance->config;

    # Read from recall file.
    if ( $config->{recall} and -e $config->{recall_file} ) {
        if ( open( my $fh, "<", $config->{recall_file} ) ) {
            _parseLine( $self, $_ ) while (<$fh>);
            close($fh);
        }
        else {
            clive::Log->instance->errn( CLIVE_READ,
                "$config->{recall_file}: $!" );
        }
    }

    # From cache (grep).
    if ( $config->{cache_grep} ) {
        my $cache = clive::Cache->instance;
        foreach ( @{ $cache->grepQueue } ) {
            push( @{ $self->{queue} }, $_ );
        }
    }

    # Use argv.
    _parseLine( $self, $_ ) foreach (@ARGV);

    # Default to STDIN.
    if (   scalar( @{ $self->{queue} } ) == 0
        && scalar( @ARGV == 0 ) )
    {
        _parseLine( $self, $_ ) while (<STDIN>);
    }

    my $cache = clive::Cache->instance;
    my $curl  = clive::Curl->instance;
    my $log   = clive::Log->instance;

    require clive::HostFactory;
    require clive::Video;

    foreach ( @{ $self->{queue} } ) {
        my $host = clive::HostFactory->new($_);
        if ($host) {
            my $props = clive::Video->new;
            $props->page_link($_);

            my $rc = 0;

            # Read from cache.
            if ( $cache->enabled() && $config->{cache_read} ) {
                $rc = $cache->read( \$props );
                if ( $rc == 1 && $props->video_format() ne $config->{format} )
                {

                    # Cache: video format != requested format -> re-fetch.
                    $rc = 0;
                }
            }

            # Cache failed or record did not exist. Fetch the video page.
            if ( $rc == 0 ) {
                my $content;

                $rc = $curl->fetchToMem( $props->page_link, \$content );

                if ( $rc == 0 ) {

                    $props->page_title( \$content );
                    $rc = $host->parsePage( \$content, \$props );

                    if ( $rc == 0 ) {
                        $rc = $curl->queryFileLength( \$props );
                        if ( $rc == 0 ) {
                            $props->video_format( $config->{format} );
                            $cache->write( \$props );
                        }
                    }
                }
            }

            # Cache record found.
            else {
                $log->out("cache $_ ...done\n");
                $rc = 0;
            }

            # If everything went OK so far, proceed to extract etc.
            if ( $rc == 0 ) {

                push( @{ $self->{passed_queue} }, $_ );

                $props->formatOutputFilename;

                if ( $props->nothing_todo ) {
                    $log->err( CLIVE_NOTHINGTODO,
                        "file already retrieved; nothing todo" );
                    clive::Exec->instance->queue( \$props );
                    next;
                }

                if ( $config->{no_extract} ) {
                    $props->printVideo;
                }
                elsif ( $config->{emit_csv} ) {
                    $props->emitCSV;
                }
                else {
                    if ( $curl->fetchToFile( \$props ) == 0 ) {
                        clive::Exec->instance->queue( \$self, \$props );
                    }
                }
            }
        }
        else {
            $log->err( CLIVE_NOSUPPORT, "no support: $_" );
        }
    }

    clive::Exec->instance->runExec;

    # Update recall file.
    if ( $log->returnCode == CLIVE_OK ) {
        if ( open( my $fh, ">", $config->{recall_file} ) ) {
            print( $fh "$_\n" ) foreach ( @{ $self->{passed_queue} } );
            close($fh);
        }
        else {
            $log->errn( CLIVE_READ, "$config->{recall_file}: $!" );
        }
    }
}

sub _parseLine {
    my ( $self, $ln ) = @_;

    return if $ln =~ /^$/;
    return if $ln =~ /^#/;

    chomp $ln;

    $ln = "http://$ln"
        if $ln !~ m{^http://}i;

    # Youtube: youtube-nocookie.com -> youtube.com.
    $ln =~ s/-nocookie//;

    # Translate host specific embedded link to video page link.
    $ln =~ s!/v/!/watch?v=!i;  # youtube
    $ln =~ s!googleplayer.swf!videoplay!i;    # googlevideo
    $ln =~ s!/pl/!/videos/!i;  # sevenload
    $ln =~ s!/e/!/view?i=!i;   # liveleak

    # Lastfm demystifier.
    if ( $ln =~ /last\.fm/ ) {
        $ln =~ /\+1\-(.+)/;
        if ( !$1 ) {
            clive::Log->instance->err( CLIVE_NOSUPPORT, "no support: $ln" );
            return;
        }
        $ln = "http://youtube.com/watch?v=$1";
    }

    push( @{ $self->{queue} }, $ln );
}

sub _printHosts {
    require clive::HostFactory;
    clive::HostFactory->dumpHosts();
    exit(CLIVE_OK);
}

1;

# There must be some kinda way out of here.
