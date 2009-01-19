package WebGUI::Flux::Modifier::Method;
use strict;

use base 'WebGUI::Flux::Modifier';
use Scalar::Util qw(blessed);
use Params::Validate qw(:all);

=head1 NAME

Package WebGUI::Flux::Modifier::Method

=head1 DESCRIPTION

Calls $method on the Operand.

See WebGUI::Flux::Modifier base class for more information.

=cut

#-------------------------------------------------------------------

=head2 evaluate

See WebGUI::Flux::Modifier base class for more information.

=cut

sub evaluate {
    my ($self) = @_;

    # Assemble the ingredients..
    my $method = $self->args()->{method};
    my @args   = @{ $self->args()->{args} || [] };
    my $obj    = $self->operand();

    if ( !blessed $obj) {
        $self->session->log->warn("Operand not a blessed object");
        return;
    }

    if ( !$obj->can($method) ) {
        $self->session->log->warn("Operand does not support method: $method");
        return;
    }

    return $obj->$method(@args);
}

#-------------------------------------------------------------------

=head2 definition

See WebGUI::Flux::Modifier base class for more information.

=cut

sub definition {
    return { args => { method => 1, args => { type => ARRAYREF, optional => 1 } } };
}

1;
