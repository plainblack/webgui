package WebGUI::Flux::Operand::NumericValue;
use strict;
use warnings;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::NumericValue

=head1 DESCRIPTION

Numeric Value (includes integers and floating point numbers)

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
