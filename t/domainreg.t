#!perl -T

use Test::More tests => 3;
use WWW::Namecheap::API;

my $api = WWW::Namecheap::API->new(
    System => 'test',
    ApiUser => 'wwwnamecheapapi',
    ApiKey => '384bac5cb5784231b3b43e3f4fd31e2e',
    DefaultIp => '108.4.146.235',
);

isa_ok($api, 'WWW::Namecheap::API');

my %create = (
    DomainName => "wwwnamecheapapi$$.com",
    Years => 1,
    Registrant => {
        OrganizationName => 'WWW-Namecheap-API',
        FirstName => 'Create',
        LastName => 'Test',
        Address1 => '123 Fake Street',
        City => 'Univille',
        StateProvince => 'SD',
        PostalCode => '12345',
        Country => 'USA',
        Phone => '+1.2125551212',
        EmailAddress => 'twilde@cpan.org',
    },
);

my $result = $api->domaincreate(%create);
is($result->{Domain}, "wwwnamecheapapi$$.info", 'Registered domain');
is($result->{Registered}, 'true', 'Registration success');
