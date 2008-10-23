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
