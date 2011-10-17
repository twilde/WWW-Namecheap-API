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

my $transfername = "wwwncapitransfer$$.com";
my $transfer = $api->domain->transfer(
    DomainName => $transfername,
    Years => 1,
    EPPCode => 'thisismyEPP',
);

is($transfer->{Transfer}, 'true');
like($transfer->{TransferID}, qr/^\d+$/);

my $status = $api->domain->transferstatus(TransferID => $transfer->{TransferID});
is($status->{TransferID}, $transfer->{TransferID});
like($status->{StatusID}, qr/^-?\d+$/);

my $transferlist = $api->domain->transferlist;

ok(grep { $_ eq $transfer->{TransferID} } map { $_->{ID} } @$transferlist);
ok(grep { $_ eq $transfername } map { $_->{Domainname} } @$transferlist);

done_testing(7);
