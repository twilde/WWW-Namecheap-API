package WWW::Namecheap::Domain;

use 5.006;
use strict;
use warnings;
use Carp();
use Data::Dumper();

=head1 NAME

WWW::Namecheap::Domain - Namecheap API domain methods

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Namecheap API domain methods.

Perhaps a little code snippet.

    use WWW::Namecheap::Domain;

    my $foo = WWW::Namecheap::Domain->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my $class = shift;
    
    my $params = _argparse(@_);
    
    for (qw(API)) {
        Carp::croak("${class}->new(): Mandatory parameter $_ not provided.") unless $params->{$_};
    }
    
    my $self = {
        api => $params->{'API'},
    };
    
    return bless($self, $class);
}

=head2 $domain->check

Check a list of domains.

=cut

sub check {
    my $self = shift;
    
    my $params = _argparse(@_);
    
    my %domains = map { $_ => -1 } @{$params->{'domains'}};
    my $DomainList = join(',', keys %domains);
    my $xml = $self->api->request(
        Command => 'namecheap.domains.check',
        ClientIp => $params->{'ClientIp'},
        UserName => $params->{'UserName'},
        DomainList => $DomainList,
    );
    
    if ($xml->{Status} eq 'ERROR') {
        print STDERR Data::Dumper::Dumper \$xml;
        return;
    }
    
    foreach my $entry (@{$xml->{CommandResponse}->{DomainCheckResult}}) {
        unless ($domains{$entry->{Domain}}) {
            Carp::carp("Unexpected domain found: $entry->{Domain}");
            next;
        }
        if ($entry->{Available} eq 'true') {
            $domains{$entry->{Domain}} = 1;
        } else {
            $domains{$entry->{Domain}} = 0;
        }
    }
    
    return \%domains;
}

=head2 $domain->create

Example:

  $domain->create(
      UserName => 'username', # optional if DefaultUser specified in $api
      ClientIp => '1.2.3.4', # optional if DefaultIp specified in $api
      DomainName => 'example.com',
      Years => 1,
      Registrant => {
          OrganizationName => 'Example Dot Com', # optional
          FirstName => 'Domain',
          LastName => 'Manager',
          Address1 => '123 Fake Street',
          Address2 => 'Suite 555', # optional
          City => 'Univille',
          StateProvince => 'SD',
          StateProvinceChoice => 'S', # for 'State' or 'P' for 'Province'
          PostalCode => '12345',
          Country => 'USA',
          Phone => '+1.2025551212',
          Fax => '+1.2025551212', # optional
          EmailAddress => 'foo@example.com',
      },
      Tech => {
          # same fields as Registrant
      },
      Admin => {
          # same fields as Registrant
      },
      AuxBilling => {
          # same fields as Registrant
      },
      Nameservers => 'ns1.foo.com,ns2.bar.com', # optional
      AddFreeWhoisguard => 'yes', # or 'no', default 'yes'
      WGEnabled => 'yes', # or 'no', default 'yes'
  );

Unspecified contacts will be automatically copied from the registrant, which
must be provided.

=cut

sub create {
    my $self = shift;
    
    my $params = _argparse(@_);
    
    my %request = (
        Command => 'namecheap.domains.create',
        ClientIp => $params->{'ClientIp'},
        UserName => $params->{'UserName'},
        DomainName => $params->{'DomainName'},
        Years => $params->{Years},
        Nameservers => $params->{'Nameservers'},
        AddFreeWhoisguard => $params->{'AddFreeWhoisguard'} || 'yes',
        WGEnabled => $params->{'WGEnabled'} || 'yes',
    );
    
    foreach my $contact (qw(Registrant Tech Admin AuxBilling)) {
        $params->{$contact} ||= $params->{Registrant};
        map { $request{"$contact$_"} = $params->{$contact}{$_} } keys %{$params->{$contact}};
    }
    
    my $xml = $self->api->request(%request);

    if ($xml->{Status} eq 'ERROR') {
        print STDERR Data::Dumper::Dumper \$xml;
        return;
    }
    
    return $xml->{CommandResponse}->{DomainCreateResult};
}

=head2 $domain->list

Get a list of domains.  Automatically "pages" through for you because it's
awesome like that.

=cut

sub list {
    my $self = shift;
    
    my $params = _argparse(@_);
    
    my %request = (
        Command => 'namecheap.domains.getList',
        ClientIp => $params->{'ClientIp'},
        UserName => $params->{'UserName'},
        PageSize => 100,
        Page => 1,
        ListType => $params->{'ListType'},
        SearchTerm => $params->{'SearchTerm'},
    );
    
    my @domains;
    
    my $break = 0;
    while (1) {
        my $xml = $self->api->request(%request);
        
        if ($xml->{Status} eq 'ERROR') {
            print STDERR Data::Dumper::Dumper \$xml;
            last;
        }
        
        #print STDERR Data::Dumper::Dumper \$xml;
        
        push(@domains, @{$xml->{CommandResponse}->{DomainGetListResult}->{Domain}});
        if ($xml->{CommandResponse}->{Paging}->{TotalItems} <= ($request{Page} * $request{PageSize})) {
            last;
        } else {
            $request{Page}++;
        }
    }
    
    return \@domains;
}

=head2 $domain->getcontacts

=cut

sub getcontacts {
    my $self = shift;
    
    my $params = _argparse(@_);
    
    return unless $params->{'DomainName'};
    
    my %request = (
        Command => 'namecheap.domains.getContacts',
        %$params,
    );
    
    my $xml = $self->api->request(%request);
    
    if ($xml->{Status} eq 'ERROR') {
        print STDERR Data::Dumper::Dumper \$xml;
        return;
    }
    
    return $xml->{CommandResponse}->{DomainContactsResult};
}

=head2 $domain->gettldlist

=cut

sub gettldlist {
    my $self = shift;
    
    my $params = _argparse(@_);
    
    my %request = (
        Command => 'namecheap.domains.getTldList',
        %$params,
    );
    
    if (!$self->{_tldlist_cachetime} || time() - $self->{_tldlist_cachetime} > 3600) {
        my $xml = $self->api->request(%request);
        $self->{_tldlist_cache} = $xml->{CommandResponse}->{Tlds}->{Tld};
        $self->{_tldlist_cachetime} = time();
    }
    
    return $self->{_tldlist_cache};
}

=head2 $domain->transfer

=cut

sub transfer {
    my $self = shift;
    
    my $params = _argparse(@_);
    
    my %request = (
        Command => 'namecheap.domains.transfer.create',
        %$params,
    );
    
    my $xml = $self->api->request(%request);
    
    if ($xml->{Status} eq 'ERROR') {
        print STDERR Data::Dumper::Dumper \$xml;
        return;
    }
    
    return $xml->{CommandResponse}->{DomainTransferCreateResult};
}

=head2 $domain->transferstatus

=cut

sub transferstatus {
    my $self = shift;
    
    my $params = _argparse(@_);
    
    my %request = (
        Command => 'namecheap.domains.transfer.getStatus',
        %$params,
    );
    
    my $xml = $self->api->request(%request);
    
    if ($xml->{Status} eq 'ERROR') {
        print STDERR Data::Dumper::Dumper \$xml;
        return;
    }
    
    return $xml->{CommandResponse}->{DomainTransferGetStatusResult};
}

=head2 $domain->transferlist

=cut

sub transferlist {
    my $self = shift;
    
    my $params = _argparse(@_);
    
    my %request = (
        Command => 'namecheap.domains.transfer.getList',
        ClientIp => $params->{'ClientIp'},
        UserName => $params->{'UserName'},
        PageSize => 100,
        Page => 1,
        ListType => $params->{'ListType'},
        SearchTerm => $params->{'SearchTerm'},
    );
    
    my @transfers;
    
    my $break = 0;
    while (1) {
        my $xml = $self->api->request(%request);
        
        if ($xml->{Status} eq 'ERROR') {
            print STDERR Data::Dumper::Dumper \$xml;
            last;
        }
        
        #print STDERR Data::Dumper::Dumper \$xml;
        
        push(@transfers, @{$xml->{CommandResponse}->{TransferGetListResult}->{Transfer}});
        if ($xml->{CommandResponse}->{Paging}->{TotalItems} <= ($request{Page} * $request{PageSize})) {
            last;
        } else {
            $request{Page}++;
        }
    }
    
    return \@transfers;
}

=head2 $domain->api()

Accessor for internal API object.

=cut

sub api {
    return $_[0]->{api};
}

sub _argparse {
    my $hashref;
    if (@_ % 2 == 0) {
        $hashref = { @_ }
    } elsif (ref($_[0]) eq 'HASH') {
        $hashref = \%{$_[0]};
    }
    return $hashref;
}

=head1 AUTHOR

Tim Wilde, C<< <twilde at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-namecheap-api at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Namecheap-API>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Namecheap::Domain


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Namecheap-API>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Namecheap-API>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Namecheap-API>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Namecheap-API/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Tim Wilde.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::Namecheap::Domain
