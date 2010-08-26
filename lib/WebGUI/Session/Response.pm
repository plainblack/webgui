package WebGUI::Session::Response;
use strict;
use parent qw(Plack::Response);

use Plack::Util::Accessor qw(session streaming writer streamer);

=head1 SYNOPSIS

    my $session = WebGUI::Session->open(...);
    my $response = $session->response;

=head1 DESCRIPTION

WebGUI's PSGI response utility class. Sub-classes L<Plack::Response>.

An instance of this object is created automatically when the L<WebGUI::Session>
is created.

=cut

=head2 stream

=cut

sub stream {
    my $self = shift;
    $self->streamer(shift);
    $self->streaming(1);
}

=head2 stream_write

=cut

sub stream_write {
    my $self = shift;
    if (!$self->streaming) {
        Carp::carp("stream_write can only be called inside streaming response");
        return;
    }
    $self->writer->write(@_);
}

1;
