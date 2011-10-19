#!perl -T

use Test::More;
use Test::Deep;
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

my %cleanslate = (
    EmailType => 'FWD',
    Hosts => [],
);

my @scenarios = (
    {
        DomainName => 'wwwnamecheapapi37272.com',
        EmailType => 'FWD',
        Hosts => [
            {
                Name => '@',
                Type => 'A',
                Address => '172.16.76.54',
            },
            {
                Name => '@',
                Type => 'AAAA',
                Address => '2001:db8:0:dead:beef:42::1',
                TTL => 3600,
            },
            {
                Name => 'www',
                Type => 'CNAME',
                Address => 'wwwnamecheapapi37272.com.',
            },
        ],
    },
    {
        DomainName => 'wwwnamecheapapi28897.com',
        EmailType => 'MX',
        Hosts => [
            {
                Name => '@',
                Type => 'URL301',
                Address => 'http://www.wwwnamecheapapi28897.com/',
                TTL => 1800, # value appears to be ignored for type=URL301
            },
            {
                Name => 'www',
                Type => 'A',
                Address => '10.42.42.42',
                TTL => 60,
            },
            {
                Name => '@',
                Type => 'MX',
                Address => 'mail.example.com.',
                MXPref => 4,
            },
            {
                Name => '@',
                Type => 'MX',
                Address => 'mail2.example.com.',
                MXPref => 42,
            },
        ],
    },
    {
        DomainName => 'wwwnamecheapapi50602.com',
        EmailType => 'MXE',
        Hosts => [
            {
                Name => '@',
                Type => 'AAAA',
                Address => '2001:DB8:0:dead::beef',
                TTL => 14400,
            },
            {
                Name => 'mail',
                Type => 'MXE',
                Address => '192.168.222.123',
            },
        ],
    },
#    {
#        DomainName => 'wwwnamecheapapi38381.com',
#    },
);

foreach my $scenario (@scenarios) {
    my $setresult = $api->dns->sethosts($scenario);
    is($setresult->{Domain}, $scenario->{DomainName});
    is($setresult->{IsSuccess}, 'true');
    
    my $getresult = $api->dns->gethosts(DomainName => $scenario->{DomainName});
    is($getresult->{Domain}, $scenario->{DomainName});
    is($getresult->{IsUsingOurDNS}, 'true');
    
    #use Data::Dumper;
    #print STDERR Data::Dumper::Dumper \$getresult;
    
    # Need to build a hash of names and data from each side of the
    # result, then compare the two sides.
    cmp_deeply($getresult->{host}, bag(map { superhashof($_) } @{$scenario->{Hosts}}));
    
    # Reset to a clean slate so our next test run has something to change
    my $cleanresult = $api->dns->sethosts(DomainName => $scenario->{DomainName}, %cleanslate);
    is($cleanresult->{Domain}, $scenario->{DomainName});
    is($setresult->{IsSuccess}, 'true');
    
    $tests += 7;
}
    
done_testing($tests);
