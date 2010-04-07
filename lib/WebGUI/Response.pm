package WebGUI::Response;
use strict;
use parent qw(Plack::Response);

use Plack::Util::Accessor qw(session streaming writer streamer);

=head2 DESCRIPTION

The WebGUI server response object. See of L<Plack::Response>

=cut

sub stream {
    my $self = shift;
    $self->streamer(shift);
    $self->streaming(1);
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