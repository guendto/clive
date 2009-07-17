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
package clive::Video;

use warnings;
use strict;

use Carp;
use POSIX;
use File::Basename qw(basename);
use File::Spec::Functions;
use Cwd qw(getcwd);

use clive::Util;

our $AUTOLOAD;

sub new {
    my $class  = shift;
    my %fields = (
        page_link      => undef,
        video_id       => undef,
        file_length    => undef,
        content_type   => undef,
        file_suffix    => undef,
        video_link     => undef,
        video_host     => undef,
        video_format   => undef,
        base_filename  => undef,
        filename       => undef,
        initial_length => undef,
        time_stamp     => undef,
        nothing_todo   => undef,
    );
    my $self = {
        _permitted => \%fields,
        %fields,
    };
    return bless( $self, $class );
}

sub page_title {
    my $self = shift;
    if (@_) {
        my ( $content, $title ) = @_;
        if ( !$title ) {
            require HTML::TokeParser;
            my $p = HTML::TokeParser->new($content);
            $p->get_tag("title");
            $self->{page_title} = $p->get_trimmed_text;
            _cleanupTitle($self);
        }
        else {
            $self->{page_title} = $title;
        }
    }
    return $self->{page_title};
}

sub printVideo {
    my $self = shift;
    my $str  = sprintf(
        "file: %s  %.1fM  [%s]\n",
        $self->{base_filename},
        clive::Util::toMB( $self->{file_length} ),
        $self->{content_type}
    );
    clive::Log->instance->out($str);
}

sub emitCSV {
    my $self = shift;

    require URI::Escape;

    my @fields = qw(base_filename file_length video_link);

    my $str = "csv:";
    $str .= sprintf( qq/"%s",/, $self->$_ ) foreach (@fields);
    $str =~ s/,$//;

    clive::Log->instance->out("$str\n");
}

sub formatOutputFilename {
    my $self = shift;

    my $config = clive::Config->instance->config;
    my $fname;

    if ( !$config->{output_file} ) {

        # Apply character-class.
        my $title = $self->{page_title};
        my $cclass = $config->{cclass} || qr|\w|;

        $title = join( '', $self->{page_title} =~ /$cclass/g )
            if ( !$config->{no_cclass} );

        # Format output filename.
        $fname = $config->{filename_format} || "%t.%s";

        $title ||= $self->{video_id}
            if ( $fname !~ /%i/ );

        $fname =~ s/%t/$title/;
        $fname =~ s/%s/$self->{file_suffix}/;
        $fname =~ s/%i/$self->{video_id}/;
        $fname =~ s/%h/$self->{video_host}/;

        my $config = clive::Config->instance->config;
        $fname = catfile( $config->{save_dir} || getcwd, $fname );

        my $tmp = $fname;

        for ( my $i = 1; $i < 9999; ++$i ) {
            $self->{initial_length} = clive::Util::fileExists($fname);

            if ( $self->{initial_length} == 0 ) {
                last;
            }
            elsif ( $self->{initial_length} == $self->{file_length} ) {
                $self->{nothing_todo} = 1;
                last;
            }
            else {
                if ( $config->{continue} ) {
                    last;
                }
            }
            $fname = "$tmp.$i";
        }
    }
    else {
        $self->{initial_length}
            = clive::Util->fileExists( $config->{output_file} );
        if ( $self->{initial_length} == $self->{file_length} ) {
            $self->{nothing_todo} = 1;
        }
        else {
            $fname = $config->{output_file};
        }
    }

    if ( !$config->{continue} ) {
        $self->{initial_length} = 0;
    }

    $self->{base_filename} = basename($fname);
    $self->{filename}      = $fname;
}

sub fromCacheRecord {
    my ( $self, $record ) = @_;

    # No need to keep order in sync with clive::Video::toCacheRecord
    # or clive::Cache::_mapRecord -- just make sure each item gets
    # set here.
    $self->{page_title}   = $$record{page_title};
    $self->{page_link}    = $$record{page_link};
    $self->{video_id}     = $$record{video_id};
    $self->{video_link}   = $$record{video_link};
    $self->{video_host}   = $$record{video_host};
    $self->{video_format} = $$record{video_format};
    $self->{file_length}  = $$record{file_length};
    $self->{file_suffix}  = $$record{file_suffix};
    $self->{content_type} = $$record{content_type};
    $self->{time_stamp}   = $$record{time_stamp};

    _cleanupTitle($self);
}

sub toCacheRecord {
    my $self = shift;

    # Should really remove all '#' from the strings
    # before storing them. Living on the edge.
    $self->{page_title} =~ tr{#}//d;

    # Keep the order in sync with clive::Cache::_mapRecord.
    my $record
        = $self->{page_title} . "#"
        . $self->{page_link} . "#"
        . $self->{video_id} . "#"
        . $self->{video_link} . "#"
        . $self->{video_host} . "#"
        . $self->{video_format} . "#"
        . $self->{file_length} . "#"
        . $self->{file_suffix} . "#"
        . $self->{content_type} . "#"
        . POSIX::strftime( "%F %T", localtime )    # time_stamp
        ;
    return $record;
}

sub _cleanupTitle {
    my $self  = shift;
    my $title = $self->{page_title};

    $title =~ s/(youtube|video|liveleak.com|sevenload|dailymotion)//gi;
    $title =~ s/(cctv.com|redtube)//gi;

    $title =~ s/^[-\s]+//;
    $title =~ s/\s+$//;

    $self->{page_title} = $title;
}

sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self)
        or croak("$self is not an object");
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    unless ( exists( $self->{_permitted}->{$name} ) ) {
        croak("cannot access `$name' field in class $type");
    }
    if (@_) {
        return $self->{$name} = shift;
    }
    else {
        return $self->{$name};
    }
}

1;

# Barefoot servants too.
