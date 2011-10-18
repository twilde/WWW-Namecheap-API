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
        StateProvince => 'SD',
        PostalCode => '12345',
        Country => 'US',
        Phone => '+1.2125551212',
        EmailAddress => 'twilde@cpan.org',
    },
);

my $result = $api->domain->create(%create);
is($result->{Domain}, "wwwnamecheapapi$$.com", 'Registered domain');
is($result->{Registered}, 'true', 'Registration success');
like($result->{DomainID}, qr/^\d+$/);
like($result->{OrderID}, qr/^\d+$/);
like($result->{TransactionID}, qr/^\d+$/);
like($result->{ChargedAmount}, qr/^\d+[.]\d+$/);

my $tests = 7;

my $contacts = $api->domain->getcontacts(DomainName => $create{DomainName});
foreach my $key (keys %{$create{Registrant}}) {
    if ($key eq 'StateProvince') {
        is($contacts->{Registrant}->{StateProvinceChoice}, $create{Registrant}->{$key});
        is($contacts->{Tech}->{StateProvinceChoice}, $create{Registrant}->{$key});
        is($contacts->{Admin}->{StateProvinceChoice}, $create{Registrant}->{$key});
        is($contacts->{AuxBilling}->{StateProvinceChoice}, $create{Registrant}->{$key});
    } else {
        is($contacts->{Registrant}->{$key}, $create{Registrant}->{$key});
        is($contacts->{Tech}->{$key}, $create{Registrant}->{$key});
        is($contacts->{Admin}->{$key}, $create{Registrant}->{$key});
        is($contacts->{AuxBilling}->{$key}, $create{Registrant}->{$key});
    }
    $tests += 4;
}

#use Data::Dumper();
#print STDERR Data::Dumper::Dumper \$contacts;

done_testing($tests);
