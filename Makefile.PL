use warnings;
use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'clive',
    ( $[ >= 5.8 )
    ? ( 'AUTHOR'     => 'Toni Gundogdu <legatvs at sign gmail com>',
        'ABSTRACT' => 'Command line video extraction tool'
        )
    : (),
    'VERSION_FROM' => 'bin/clive',
    'EXE_FILES' => ['bin/clive'],
    'PREREQ_PM' => {
# Earlier versions may work. The module has been confirmed to work with:
'WWW::Quvi'        => 0.01, # <http://www-quvi.googlecode.com/>
'WWW::Curl'        => 4.12, # <http://search.cpan.org/perldoc?WWW::Curl>
'Getopt::ArgvFile' => 1.11, # <http://search.cpan.org/perldoc?Getopt::ArgvFile>
'version'          => 0.82, # <http://search.cpan.org/perldoc?version>
# Optional:
'Term::ReadKey'    => 2.30 # <http://search.cpan.org/perldoc?Term::ReadKey>
    },
    'LICENSE' => 'gpl'
);
