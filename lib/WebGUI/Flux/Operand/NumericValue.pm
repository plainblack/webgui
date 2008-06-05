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

sub execute {
    my ($arg_ref) = @_;

    return $arg_ref->{args}{value};
}

#-------------------------------------------------------------------

=head3 getArgs

This Operand requies the following arguments

=head4 value

The number to be returned

=cut

sub getArgs {
    return { value => { type => 'number'} };
}

1;
