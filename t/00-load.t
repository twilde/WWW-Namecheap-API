#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'WWW::Namecheap::API' ) || print "Bail out!\n";
    use_ok( 'WWW::Namecheap::Domain' ) || print "Bail out!\n";
}

diag( "Testing WWW::Namecheap::API $WWW::Namecheap::API::VERSION, Perl $], $^X" );
