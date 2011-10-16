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

my %create = (
    DomainName => "wwwnamecheapapi$$.com",
    Years => 1,
    Registrant => {
        OrganizationName => 'WWW-Namecheap-API',
        FirstName => 'Create',
        LastName => 'Test',
        Address1 => '123 Fake Street',
        City => 'Univille',
        StateProvince => 'P',
        StateProvinceChoice => 'SD',
        PostalCode => '12345',
        Country => 'US',
        Phone => '+1.2125551212',
        EmailAddress => 'twilde@cpan.org',
    },
);

my $result = $api->domain->create(%create);
is($result->{Domain}, "wwwnamecheapapi$$.com", 'Registered domain');
is($result->{Registered}, 'true', 'Registration success');

my $tests = 3;

my $contacts = $api->domain->getcontacts(DomainName => $create{DomainName});
foreach my $key (keys %{$create{Registrant}}) {
    is($contacts->{Registrant}->{$key}, $create{Registrant}->{$key});
    is($contacts->{Tech}->{$key}, $create{Registrant}->{$key});
    is($contacts->{Admin}->{$key}, $create{Registrant}->{$key});
    is($contacts->{AuxBilling}->{$key}, $create{Registrant}->{$key});
    $tests += 4;
}

use Data::Dumper();
print STDERR Data::Dumper::Dumper \$contacts;

done_testing($tests);
