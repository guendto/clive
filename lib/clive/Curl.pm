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
package clive::Curl;

use warnings;
use strict;

use base 'Class::Singleton';

use WWW::Curl::Easy 4.05;
use Encode;
use Cwd;

my $bp;

sub init {
    my $self = shift;

    my $config = clive::Config->instance->config;

    my $c = WWW::Curl::Easy->new;
    $c->setopt( CURLOPT_USERAGENT, $config->{agent} || "Mozilla/5.0" );
    $c->setopt( CURLOPT_FOLLOWLOCATION, 1 );
    $c->setopt( CURLOPT_AUTOREFERER,    1 );
    $c->setopt( CURLOPT_HEADER,         1 );
    $c->setopt( CURLOPT_NOBODY,         0 );

    $c->setopt( CURLOPT_VERBOSE, 1 )
      if $config->{debug};

    $c->setopt( CURLOPT_PROXY, $config->{proxy} )
      if $config->{proxy};

    $self->{handle} = $c;
}

sub setTimeout {
    my ( $self, $no_socks_timeout ) = @_;

    my $config = clive::Config->instance->config;

    $self->{handle}
      ->setopt( CURLOPT_CONNECTTIMEOUT, $config->{connecttimeout} || 30 );

    $self->{handle}
      ->setopt( CURLOPT_TIMEOUT, $config->{connecttimeoutsocks} || 30 )
      unless $no_socks_timeout;
}

sub resetTimeout {

    # Resetting SOCKS timeout is sufficient.
    my $self = shift;
    $self->{handle}->setopt( CURLOPT_TIMEOUT, 0 );
}

sub fetchToMem {
    my ( $self, $url, $content, $what ) = @_;

    my $log = clive::Log->instance;

    my $_what = $what || $url;
    $log->out("fetch $_what ...");

    $self->{handle}->setopt( CURLOPT_URL,      $url );
    $self->{handle}->setopt( CURLOPT_ENCODING, "" );

    $$content = "";
    open( my $fh, ">", $content );

    $self->{handle}->setopt( CURLOPT_WRITEDATA, $fh );

    setTimeout($self);
    my $rc = $self->{handle}->perform;
    resetTimeout($self);

    close($fh);

    if ( $rc == 0 ) {
        my $httpcode = $self->{handle}->getinfo(CURLINFO_RESPONSE_CODE);
        if ( $httpcode == 200 ) {
            $log->out("done.\n");
            $rc = 0;
        }
        else {
            $log->errn(
                $self->{handle}->strerror($httpcode) . " (http/$httpcode)" );
            $rc = 1;
        }
    }
    else {
        $log->errn( $self->{handle}->strerror($rc) . " (http/$rc)" );
        $rc = 1;
    }
    decode_utf8($$content);
    return ($rc);
}

sub queryFileLength {
    my ( $self, $props ) = @_;

    my $log = clive::Log->instance;
    $log->out("verify video link ...");

    my $buffer = "";
    open( my $fh, ">", \$buffer );

    $self->{handle}->setopt( CURLOPT_URL,       $$props->video_link );
    $self->{handle}->setopt( CURLOPT_WRITEDATA, $fh );

    # GET -> HEAD.
    $self->{handle}->setopt( CURLOPT_NOBODY, 1 );

    setTimeout($self);
    my $rc = $self->{handle}->perform;
    resetTimeout($self);
    close($fh);

    # HEAD -> GET.
    $self->{handle}->setopt( CURLOPT_HTTPGET, 1 );

    if ( $rc == 0 ) {
        my $httpcode = $self->{handle}->getinfo(CURLINFO_RESPONSE_CODE);
        if ( $httpcode == 200 || $httpcode == 206 ) {
            $$props->file_length(
                $self->{handle}->getinfo(CURLINFO_CONTENT_LENGTH_DOWNLOAD) );

            my $content_type = $self->{handle}->getinfo(CURLINFO_CONTENT_TYPE);
            $$props->content_type($content_type);

            # Figure out file suffix.
            if ( $content_type =~ /\/(.*)/ ) {
                my $suffix = $1;    # Default to whatever was matched.
                if (   $1 =~ /octet/
                    || $1 =~ /x\-flv/
                    || $1 =~ /plain/ )
                {

                    # Otherwise use "flv" for the above exceptions.
                    $suffix = "flv";
                }
                $$props->file_suffix($suffix);
                $log->out("done.\n");
                return (0);
            }
            else {
                $log->errn("$content_type: unexpected content-type");
            }
        }
        else {
            $log->errn(
                $self->{handle}->strerror($httpcode) . " (http/$httpcode)" );
        }
    }
    else {
        $log->errn( $self->{handle}->strerror($rc) . " (http/$rc)" );
    }
    return (1);
}

sub fetchToFile {
    my ( $self, $props ) = @_;

    my $log     = clive::Log->instance;
    my $config  = clive::Config->instance->config;
    my $initial = $$props->initial_length;
    my $mode    = ">";

    if ( $config->{continue} && $initial > 0 ) {
        my $remaining = $$props->file_length - $initial;
        $log->out(
            sprintf(
                "from: %d (%.1fM)  remaining: %d (%.1fM)\n",
                $initial,   clive::Util::toMB($initial),
                $remaining, clive::Util::toMB($remaining)
            )
        );
        $mode = ">>";
    }

    my $fpath = $$props->filename;

    open( my $fh, $mode, $fpath )
      or die("$fpath: $!");

    $self->{handle}->setopt( CURLOPT_URL,         $$props->video_link );
    $self->{handle}->setopt( CURLOPT_ENCODING,    "identity" );
    $self->{handle}->setopt( CURLOPT_WRITEDATA,   $fh );
    $self->{handle}->setopt( CURLOPT_HEADER,      0 );
    $self->{handle}->setopt( CURLOPT_RESUME_FROM, $$props->initial_length );

    $self->{handle}->setopt( CURLOPT_PROGRESSFUNCTION, \&progress_callback );
    $self->{handle}->setopt( CURLOPT_NOPROGRESS,       0 );

    require clive::Progress::Bar;
    $bp = clive::Progress::Bar->new($props);

    if ( $config->{limit_rate} ) {
        $self->{handle}->setopt( CURLOPT_MAX_RECV_SPEED_LARGE,
            $config->{limit_rate} * 1024 );
    }

    setTimeout( $self, 1 );    # 1=Do not enable SOCKS timeout.
    my $rc = $self->{handle}->perform;
    resetTimeout($self);

    close($fh);

    $self->{handle}->setopt( CURLOPT_MAX_RECV_SPEED_LARGE, 0 );
    $self->{handle}->setopt( CURLOPT_HEADER,               1 );
    $self->{handle}->setopt( CURLOPT_NOPROGRESS,           1 );
    $self->{handle}->setopt( CURLOPT_RESUME_FROM,          0 );

    if ( $rc == 0 ) {
        my $httpcode = $self->{handle}->getinfo(CURLINFO_RESPONSE_CODE);
        if ( $httpcode == 200 || $httpcode == 206 ) {
            $bp->finish();
        }
        else {
            $log->errn(
                $self->{handle}->strerror($httpcode) . " (http/$httpcode)" );
            return (1);
        }
    }
    else {
        $log->errn( $self->{handle}->strerror($rc) . " (rc/$rc)" );
        return (1);
    }

    $log->out("\n");
    clive::Exec->instance->resetStream;

    return (0);
}

sub progress_callback {
    my ( $percent, $props ) = $bp->update(@_);
    clive::Exec->instance->runStream( $percent, $props );
    return (0);    # 0 == OK
}

1;

# At night or strolling through the park.
