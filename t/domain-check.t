#!perl -T

use Test::More tests => 2;
use WWW::Namecheap::API;

my $api = WWW::Namecheap::API->new(
    System => 'test',
    ApiUser => 'wwwnamecheapapi',
    ApiKey => '384bac5cb5784231b3b43e3f4fd31e2e',
    DefaultIp => '108.4.146.235',
);

isa_ok($api, 'WWW::Namecheap::API');

my $expected_result = {
    'example.com' => 0,
    'asdfaskqwjqkfjaslfkeia.com' => 1,
    'thisisalongbadfaketestdomain.com' => 1,
    'wwwnamecheapapi50602.com' => 0,
};

is_deeply($api->domain->check(Domains => [keys %$expected_result]), $expected_result);
