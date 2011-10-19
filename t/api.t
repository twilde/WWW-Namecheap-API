#!perl -T

use Test::More tests => 5;
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

my $dns = $api->dns;
isa_ok($dns, 'WWW::Namecheap::DNS');

my $dns2 = WWW::Namecheap::DNS->new(API => $api);
is_deeply($dns, $dns2);
