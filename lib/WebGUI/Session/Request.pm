package WebGUI::Session::Request;

use strict;
use warnings;

=head1 DESCRIPTION

This class wraps calls to $session->request and logs them as a cute way of seeing
what Apache2::* methods webgui is calling

=cut

sub new {
    my $class = shift;
    bless { @_ }, $class;
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $what = $AUTOLOAD;
    $what =~ s/.*:://;
    my $r = $self->{r};
    my $session = $self->{session};

    if ( !$r ) {
        $session->log->error("!!request->$what(@_) but r not defined");
        return;
    }

    if ( $what eq 'print' ) {
        $session->log->error("!!request->$what(print--chomped)");
    }
    else {
        $session->log->error("!!request->$what(@_)");
    }
    return $r->$what(@_);
}

1;
