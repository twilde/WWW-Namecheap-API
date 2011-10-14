use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Namecheap::API',
    license             => 'perl',
    dist_author         => q{Tim Wilde <twilde@cpan.org>},
    dist_version_from   => 'lib/WWW/Namecheap/API.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
        'LWP' => 0,
    },
    add_to_cleanup      => [ 'WWW-Namecheap-API-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
