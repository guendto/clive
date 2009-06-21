use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'clive',
    ( $[ >= 5.8 )
    ? ( AUTHOR     => 'Toni Gundogdu <legatvs@gmail.com>',
        'ABSTRACT' => 'command line video extraction utility'
        )
    : (),
    'VERSION'   => '2.2.2',
    'EXE_FILES' => ['bin/clive'],
    'PREREQ_PM' => {
        'Getopt::ArgvFile' => 1.11,
        'Class::Singleton' => 1.4,
        'HTML::TokeParser' => 2.37,
        'URI::Escape'      => 3.29,
        'Digest::SHA'      => 5.45,
        'WWW::Curl'        => 4.05,
    },
    'LICENSE' => 'gpl',
    dist      => {
        COMPRESS => "bzip2",
        SUFFIX   => ".bz2"
    },
);
