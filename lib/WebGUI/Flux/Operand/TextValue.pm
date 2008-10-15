package WebGUI::Flux::Operand::TextValue;
use strict;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::TextValue

=head1 DESCRIPTION

Text Value

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

sub evaluate {
    my ($self) = @_;

    return $self->args()->{value};
}

#-------------------------------------------------------------------

sub definition {
    return { args => { value => 1 } };
}

1;
