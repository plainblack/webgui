package WebGUI::Flux::Operand::TruthValue;
use strict;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::TruthValue

=head1 DESCRIPTION

Boolean True of False

In terms of logic, Flux doesn't really see any difference between 
this Operand and TextValue - the reason we have it is so that the UI
can present a simple True/False html input field rather than requiring 
the user to enter 0/1 into a free-text field.

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
