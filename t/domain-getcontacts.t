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
