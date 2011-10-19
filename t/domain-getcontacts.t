#!perl -T

use Test::More;
use WWW::Namecheap::API;

plan skip_all => "No API credentials defined" unless $ENV{TEST_APIUSER};

my $api = WWW::Namecheap::API->new(
    System => 'test',
    ApiUser => $ENV{TEST_APIUSER},
    ApiKey => $ENV{TEST_APIKEY},
    DefaultIp => $ENV{TEST_APIIP} || '127.0.0.1',
);

isa_ok($api, 'WWW::Namecheap::API');

my %expected = (
    OrganizationName => 'WWW-Namecheap-API',
    FirstName => 'Create',
    LastName => 'Test',
    Address1 => '123 Fake Street',
    City => 'Univille',
    StateProvince => 'State',
    StateProvinceChoice => 'SD',
    PostalCode => '12345',
    Country => 'US',
    Phone => '+1.2125551212',
    Fax => '+1.5555555555',
    EmailAddress => 'twilde@cpan.org',
    ReadOnly => 'false',
);

my $contacts = $api->domain->getcontacts(DomainName => 'wwwnamecheapapi38449.com');
is($contacts->{Domain}, 'wwwnamecheapapi38449.com');

my $tests = 2;

foreach my $contact (qw(Registrant Tech Admin AuxBilling)) {
    foreach my $key (keys %{$contacts->{$contact}}) {
        if ($expected{$key}) {
            is($contacts->{$contact}->{$key}, $expected{$key});
        } else {
            ok(ref($contacts->{$contact}->{$key}) eq 'HASH'
               && keys(%{$contacts->{$contact}->{$key}}) == 0,
               'Blank expected == empty hash')
        }
        $tests++;
    }
}

done_testing($tests);
