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
# Earlier versions may work.
'Getopt::ArgvFile' => 1.11, # <http://search.cpan.org/perldoc?Getopt::ArgvFile>
'JSON::XS'         => 2.30, # <http://search.cpan.org/perldoc?JSON::XS>
'version'          => 0.77, # <http://search.cpan.org/perldoc?version>
    },
    'LICENSE' => 'gpl',
    'MAN1PODS' => { 'man1/clive.1.pod' => '$(INST_MAN1DIR)/clive.$(MAN1EXT)' }
);
