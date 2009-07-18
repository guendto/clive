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
package clive::Config;

use warnings;
use strict;

use base 'Class::Singleton';

use Getopt::ArgvFile(
    home            => 1,
    startupFilename => [qw(.cliverc .clive/config .config/clive/config)],
);

use Getopt::Long qw(:config bundling);
use File::Spec::Functions;
use File::Path qw(mkpath);
use Cwd qw(getcwd);

use clive::HostFactory;
use clive::Error qw(CLIVE_OK CLIVE_OPTARG);

use constant VERSION => "2.2.3";

sub init {
    my $self = shift;

    my %config;

    GetOptions(
        \%config,
        'debug',      'exec=s',   'cclass=s',   'stream=i',
        'continue|c', 'recall|l', 'format|f=s', 'agent=s',
        'quiet|q',    'proxy=s',  'stderr',
        'hosts'     => \&clive::HostFactory::dumpHosts,
        'version|v' => \&_printVersion,
        'help|h',   => \&_printHelp,

        # TODO: Write a wrapper for these.
        'cache_read|cache-read|cacheread|r',
        'cache_dump|cache-dump|cachedump|d',
        'cache_grep|cache-grep|cachegrep|g=s',
        'cache_remove_record|cache-remove-record|cacheremoverecord|D',
        'cache_ignore_case|cache_ignore-case|cacheignorecase|i',
        'cache_dump_format|cache-dump-format|cachedumpformat=s',
        'cache_clear|cache-clear|cacheclear',
        'no_cache|no-cache|nocache',
        'no_extract|no-extract|noextract|n',
        'no_proxy|no-proxy|noproxy',
        'filename_format|filename-format|filenameformat=s',
        'emit_csv|emit-csv|emitcsv',
        'stream_exec|stream-exec|streamexec=s',
        'output_file|output-file|outputfile|O=s',
        'limit_rate|limit-rate|limitrate=i',
        'connect_timeout|connect-timeout|connecttimeout=i',
        'connect_timeout_socks|connect-timeout-socks|connecttimeoutsocks=i',
        'save_dir|save-dir|savedir=s',
        'recall_file|recall-file|recallfile=s',
        'cache_file|cache-file|cachefile=s',
        'no_cclass|no-cclass|nocclass|C',
        'stop_after|stop-after|stopafter=s',
        'exec_run|exec-run|execrun|e',
    ) or exit(CLIVE_OPTARG);

    my $homedir = $ENV{HOME} || getcwd();

    my $cachedir = $ENV{CLIVE_CACHE}
        || catfile( $homedir, ".cache", "clive" );

    eval { mkpath($cachedir) };
    die "$cachedir: $@"
        if ($@);

    $config{recall_file} ||= catfile( $cachedir, "last" );
    $config{cache_file}  ||= catfile( $cachedir, "cache" );

    $config{format} ||= 'flv';

    # Check format.
    my @youtube = qw(fmt18 fmt35 fmt22 fmt17 hq 3gp);
    my @google  = qw(mp4);
    my @dmotion = qw(spak-mini vp6-hq vp6-hd vp6 h264);
    my @vimeo   = qw(hd);
    my @formats = ( qw(flv best), @youtube, @google, @dmotion, @vimeo );

    #unless (@formats ~~ $config{format}) { # Perl 5.10.0+
    unless ( grep( /^$config{format}$/, @formats ) ) {
        clive::Log->instance->err( CLIVE_OPTARG,
            "unsupported format `$config{format}'" );
        exit(CLIVE_OPTARG);
    }

    # Check --stream-exec and --stream.
    if ( $config{stream_exec} || $config{stream} ) {
        unless ( $config{stream_exec} && $config{stream} ) {
            clive::Log->instance->err( CLIVE_OPTARG,
                "both --stream-exec and --stream must be defined" );
            exit(CLIVE_OPTARG);
        }
    }

    # Check --stop-after.
    if ( $config{stop_after} ) {
        if (   $config{stop_after} !~ /M$/
            && $config{stop_after} !~ /%$/ )
        {
            clive::Log->instance->err( CLIVE_OPTARG,
                "--stop-after must be terminated by either '%' or 'M'" );
            exit(CLIVE_OPTARG);
        }
    }

    $self->{config} = \%config;
}

sub config {
    my $self = shift;
    return $self->{config};
}

sub _printVersion {
    my $str
        = sprintf( "clive version %s with WWW::Curl version "
            . "$WWW::Curl::VERSION  [%s].\n"
            . "Copyright (C) 2009 Toni Gundogdu.\n\n"
            . "License GPLv3+: GNU GPL version 3 or later\n"
            . "  <http://www.gnu.org/licenses/>\n\n"
            . "This is free software: you are free to change and redistribute it."
            . "\nThere is NO WARRANTY, to the extent permitted by law.\n\n"
            . "Report bugs: <http://code.google.com/p/clive/issues/>\n",
        VERSION, $^O );
    print($str);
    exit(CLIVE_OK);
}

sub _printHelp {

    # Edit bin/clive for --help contents.
    require Pod::Usage;
    Pod::Usage::pod2usage( -exitstatus => CLIVE_OK, -verbose => 1 );
}

1;

# There's too much confusion.
