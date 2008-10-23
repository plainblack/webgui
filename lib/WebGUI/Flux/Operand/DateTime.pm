package WebGUI::Flux::Operand::DateTime;
use strict;

use base 'WebGUI::Flux::Operand';
use WebGUI::DateTime;

=head1 NAME

Package WebGUI::Flux::Operand::DateTime

=head1 DESCRIPTION

DateTime Value

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

=head2 evaluate

See WebGUI::Flux::Operand base class for more information.

=cut

sub evaluate {
    my ($self) = @_;

    return WebGUI::DateTime->new($self->args()->{value});
}

#-------------------------------------------------------------------

=head2 definition

See WebGUI::Flux::Operand base class for more information.

=cut

sub definition {
    return { args => { value => 1 } };
}

1;
