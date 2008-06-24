package WebGUI::Flux::Operand::UserProfileField;
use strict;
use warnings;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::UserProfileField

=head1 DESCRIPTION

Returns the value of the specified User Profile Field for the given user 

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

sub evaluate {
    my ($self) = @_;

    my $field = $self->args()->{field};
    my $user = $self->rule()->evaluatingForUser();
    
    return $user->profileField($field);
}

#-------------------------------------------------------------------

sub definition {
    return { args => { field => 1 } };
}

1;
