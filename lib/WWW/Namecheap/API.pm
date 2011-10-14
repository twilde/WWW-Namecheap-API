package WWW::Namecheap::API;

use 5.006;
use strict;
use warnings;
use Carp();
use LWP::UserAgent();

=head1 NAME

WWW::Namecheap::API - Perl interface to the Namecheap API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our $PROD_API = 'https://api.namecheap.com/xml.response';
our $TEST_API = 'https://api.sandbox.namecheap.com/xml.response';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use WWW::Namecheap::API;

    my $foo = WWW::Namecheap::API->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub new {
    my $class = shift;
    
    my %params;
    if (@_ % 2 == 0) {
        %params = @_;
    } elsif (ref($_[0]) eq 'HASH') {
        %params = %{$_[0]};
    } else {
        Carp::croak("${class}->new(): Unknown parameter passing method.");
    }
    
    for (qw(apiuser apikey username)) {
        Carp::croak("${class}->new(): Mandatory parameter $_ not provided.") unless $params{$_};
    }
    
    my %self = (
        apiuser => $params{'apiuser'},
        apikey => $params{'apikey'},
        username => $params{'username'},
        agent => $params{'agent'} || "WWW::Namecheap::API/$VERSION",
    );
    
    return bless($self, $class);
}

sub function1 {
}

=head2 function2

=cut

sub function2 {
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
