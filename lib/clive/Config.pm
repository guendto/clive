# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
#
# Copyright 2009 Toni Gundogdu.
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
use clive::Compat;
use clive::Error qw(CLIVE_OK CLIVE_OPTARG);

use constant VERSION => "2.2.16";

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
        'license'   => \&_printLicense,
        'help|h',   => \&_printHelp,

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
        'stream_pass|stream-pass|streampass|s',
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
        'upgrade_config|upgrade-config|upgradeconfig' =>
            \&clive::Compat::upgradeConfig,
        'cookie_jar|cookie-jar|cookiejar=s',
        'print_fname|print-fname|printfname',
    ) or exit(CLIVE_OPTARG);

    my $homedir = $ENV{HOME} || getcwd();

    my $cachedir = $ENV{CLIVE_CACHE}
        || catfile( $homedir, ".cache", "clive" );

    eval { mkpath($cachedir) };
    die "$cachedir: $@"
        if ($@);

    $config{recall_file} ||= catfile( $cachedir, "last" );
    $config{cache_file}  ||= catfile( $cachedir, "cache" );

    $config{format} ||= 'default';

    # Check format.
    my @youtube = qw(fmt17 fmt18 fmt22 fmt34 fmt35 fmt37 fmt43 fmt45);
    my @youtube_new
        = qw(mobile sd_270p sd_360p hq_480p hd_720p hd_1080p webm webm_480p webm_720p);
    my @youtube_old = qw(hq 3gp);
    my @google      = qw(mp4);
    my @vimeo       = qw(hd);
    my @spiegel                # vp6_388=default
        = qw(vp6_64 vp6_576 vp6_928 h264_1400 small iphone podcast);
    my @golem = qw(high ipod); # medium=default

    my @formats = (
        qw(default best),
        @youtube, @youtube_old, @youtube_new, @google, @vimeo, @spiegel,
        @golem
    );

    #unless (@formats ~~ $config{format}) { # Perl 5.10.0+
    unless ( grep( /^$config{format}$/, @formats ) ) {
        clive::Log->instance->err( CLIVE_OPTARG,
            "unsupported format `$config{format}'" );
        exit(CLIVE_OPTARG);
    }

    my $log = clive::Log->instance;
    my $str = "%s depends on --stream-exec which is undefined";

    # Check streaming options.

    if ( $config{stream} && !$config{stream_exec} ) {
        $log->err( CLIVE_OPTARG, sprintf( $str, "--stream" ) );
        exit(CLIVE_OPTARG);
    }

    if ( $config{stream_pass} && !$config{stream_exec} ) {
        $log->err( CLIVE_OPTARG, sprintf( $str, "--stream-pass" ) );
        exit(CLIVE_OPTARG);
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

sub _printLicense {
    print
        "Copyright (C) 2007,2008,2009,2010 Toni Gundogdu. License: GNU GPL version 3+
This is free software; see the  source for  copying conditions.  There is NO
warranty;  not even for MERCHANTABILITY or FITNESS FOR A  PARTICULAR PURPOSE.
";
    exit CLIVE_OK;
}

sub _printVersion {
    printf "clive version %s with WWW::Curl version $WWW::Curl::VERSION\n"
        . "os=%s, perl=%s, locale=%s\n",
        VERSION, $^O, ( sprintf "%vd", $^V ), $ENV{LANG} || "?";
    exit CLIVE_OK;
}

sub _printHelp {

    # Edit bin/clive for --help contents.
    require Pod::Usage;
    Pod::Usage::pod2usage( -exitstatus => CLIVE_OK, -verbose => 1 );
}

1;

# There's too much confusion.
