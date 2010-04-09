package WebGUI::Session::Request;
use strict;
use parent qw(Plack::Request);
use WebGUI::Session::Response;

=head1 SYNOPSIS

    my $session = WebGUI::Session->open(...);
    my $request = $session->request;

=head1 DESCRIPTION

WebGUI's PSGI request utility class. Sub-classes L<Plack::Request>.

An instance of this object is created automatically when the L<WebGUI::Session>
is created.

=head1 METHODS

=head2 new_response ()

Creates a new L<WebGUI::Session::Response> object.

N.B. A L<WebGUI::Session::Response> object is automatically created when L<WebGUI::Session> 
is instantiated, so in most cases you will not need to call this method.
See L<WebGUI::Session/response>

=cut

sub new_response {
    my $self = shift;
    return WebGUI::Session::Response->new(@_);
}

# This is only temporary
sub TRACE { 
    shift->env->{'psgi.errors'}->print(join '', @_, "\n");
}

1;