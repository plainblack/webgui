package WebGUI::Flux::Operand::Group;
use strict;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::Group

=head1 DESCRIPTION

Returns true/false depending on whether the given user is in the specified Group 

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

sub evaluate {
    my ($self) = @_;

    my $groupId = $self->args()->{groupId};        
    my $user = $self->rule()->evaluatingForUser();
    
    return $user->isInGroup($groupId);
}

#-------------------------------------------------------------------

sub definition {
    return { args => { groupId => 1 } };
}

1;
