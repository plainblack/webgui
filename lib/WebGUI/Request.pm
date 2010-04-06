package WebGUI::Request;

=head2 DESCRIPTION

The WebGUI server response object. See L<Plack::Response>

=cut

use parent qw(Plack::Request);
use WebGUI::Response;

=head1 METHODS

=head2 new_response ()

Creates a new L<WebGUI::Response> object.

N.B. A L<WebGUI::Response> object is automatically created when L<WebGUI::Session> 
is instantiated, so in most cases you will not need to call this method.
See L<WebGUI::Session/response>

=cut

sub new_response {
    my $self = shift;
    WebGUI::Response->new(@_);
}

1;