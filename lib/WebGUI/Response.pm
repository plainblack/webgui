package WebGUI::Response;
use strict;
use parent qw(Plack::Response);

use Plack::Util::Accessor qw(streaming writer streamer);

=head2 DESCRIPTION

The WebGUI server response object. See of L<Plack::Response>

=cut

sub stream {
    my $self = shift;
    my $streamer = shift;
    $self->streaming(1);
    $self->streamer($streamer);
}

sub stream_write {
    my $self = shift;
    if (!$self->streaming) {
        Carp::carp("stream_write can only be called inside streaming response");
        return;
    }
    $self->writer->write(@_);
}

1;