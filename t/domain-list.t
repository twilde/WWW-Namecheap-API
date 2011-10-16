#!perl -T

use Test::More;
use WWW::Namecheap::API;

my $api = WWW::Namecheap::API->new(
    System => 'test',
    ApiUser => 'wwwnamecheapapi',
    ApiKey => '384bac5cb5784231b3b43e3f4fd31e2e',
    DefaultIp => '108.4.146.235',
);

isa_ok($api, 'WWW::Namecheap::API');

my $domains = $api->domain->list;
isa_ok($domains, 'ARRAY');

my $tests = 2;

foreach my $dom (@$domains) {
    like($dom->{ID}, qr/^\d+$/);
    like($dom->{Name}, qr/^[\w.-]+$/);
    is($dom->{User}, 'wwwnamecheapapi');
    like($dom->{Created}, qr{^\d{2}/\d{2}/\d{4}$});
    like($dom->{Expires}, qr{^\d{2}/\d{2}/\d{4}$});
    $tests += 5;
}

done_testing($tests);
