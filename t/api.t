#!perl -T

use Test::More tests => 3;
use WWW::Namecheap::API;
use WWW::Namecheap::Domain;

my $api = WWW::Namecheap::API->new(
    System => 'test',
    ApiUser => 'wwwnamecheapapi',
    ApiKey => '384bac5cb5784231b3b43e3f4fd31e2e',
    DefaultIp => '108.4.146.235',
);

isa_ok($api, 'WWW::Namecheap::API');

my $domain = $api->domain;

isa_ok($domain, 'WWW::Namecheap::Domain');

my $domain2 = WWW::Namecheap::Domain->new(API => $api);

is_deeply($domain, $domain2);
