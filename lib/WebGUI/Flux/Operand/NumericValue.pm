package WebGUI::Flux::Operand::NumericValue;
use strict;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::NumericValue

=head1 DESCRIPTION

Numeric Value (includes integers and floating point numbers)

In terms of logic, Flux doesn't really see any difference between 
this Operand and TextValue - the reason we have it is so that the UI
can present a nice self-validating number-picker rather than a free-text 
field.

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

=head2 evaluate

See WebGUI::Flux::Operand base class for more information.

=cut

sub evaluate {
    my ($self) = @_;

    return $self->args()->{value};
}

#-------------------------------------------------------------------

=head2 definition

See WebGUI::Flux::Operand base class for more information.

=cut

sub definition {
    return { args => { value => 1 } };
}

1;
