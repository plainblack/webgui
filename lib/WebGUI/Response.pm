package WebGUI::Response;
use parent qw(Plack::Response);

use Plack::Util::Accessor qw(streaming);

=head2 DESCRIPTION

The WebGUI server response object. See of L<Plack::Response>

=cut

sub stream {
    my $self = shift;
    my $streamer = shift;
    $self->streaming(1);
    $self->body($streamer);
}

1;