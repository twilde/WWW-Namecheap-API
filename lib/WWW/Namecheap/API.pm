package WWW::Namecheap::API;

use 5.006;
use strict;
use warnings;
use Carp();
use LWP::UserAgent ();
use URI::Escape;
use XML::Simple;
use Data::Dumper ();

# For convenience methods
use WWW::Namecheap::Domain ();

=head1 NAME

WWW::Namecheap::API - Perl interface to the Namecheap API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our %APIURL = (
    prod => 'https://api.namecheap.com/xml.response',
    test => 'https://api.sandbox.namecheap.com/xml.response',
);

=head1 SYNOPSIS

Perl interface to the Namecheap API.  Yeah, use it.

Perhaps a little code snippet.

    use WWW::Namecheap::API;

    my $foo = WWW::Namecheap::API->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my $class = shift;
    
    my $params = _argparse(@_);
    
    for (qw(ApiUser ApiKey)) {
        Carp::croak("${class}->new(): Mandatory parameter $_ not provided.") unless $params->{$_};
    }
    
    my $ua = LWP::UserAgent->new(
        agent => $params->{'Agent'} || "WWW::Namecheap::API/$VERSION",
    );
    
    my $apiurl;
    if ($params->{'ApiUrl'}) {
        $apiurl = $params->{'ApiUrl'}; # trust the user?!?!
    } else {
        if ($params->{'System'}) {
            $apiurl = $APIURL{$params->{'System'}};
        } else {
            $apiurl = $APIURL{'test'};
        }
    }
    
    my $self = {
        ApiUrl => $apiurl,
        ApiUser => $params->{'ApiUser'},
        ApiKey => $params->{'ApiKey'},
        DefaultUser => $params->{'DefaultUser'} || $params->{'ApiUser'},
        DefaultIp => $params->{'DefaultIp'},
        _ua => $ua,
    };
    
    return bless($self, $class);
}

=head2 $api->request

Send a request to the Namecheap API.

=cut

sub request {
    my $self = shift;
    my %reqparams = @_;
    
    my $clientip = delete($reqparams{'ClientIp'}) || $self->{'DefaultIp'};
    unless ($clientip) {
        Carp::carp("No Client IP or default IP specified, cannot perform request.");
        return;
    }
    my $username = delete($reqparams{'UserName'}) || $self->{'DefaultUser'};
    
    my $ua = $self->{_ua}; # convenience
    my $url = sprintf('%s?ApiUser=%s&ApiKey=%s&UserName=%s&Command=%s&ClientIp=%s&',
        $self->{'ApiUrl'}, $self->{'ApiUser'}, $self->{'ApiKey'},
        $username, delete($reqparams{'Command'}), $clientip);
    $url .= join('&', map { join('=', map { uri_escape($_) } each %reqparams) } keys %reqparams);
    #print STDERR "Sent URL $url\n";
    my $response = $ua->get($url);
    
    unless ($response->is_success) {
        Carp::carp("Request failed: " . $response->message);
        return;
    }
    
    return XMLin($response->content);
}

=head2 $api->domain

Helper method to create and return a WWW::Namecheap::Domain object utilizing
this API object.  Always returns the same object within a given session via
internal caching.

=cut

sub domain {
    my $self = shift;
    
    if ($self->{_domain}) {
        return $self->{_domain};
    }
    
    return $self->{_domain} = WWW::Namecheap::Domain->new(API => $self);
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

    perldoc WWW::Namecheap::API


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

1; # End of WWW::Namecheap::API
