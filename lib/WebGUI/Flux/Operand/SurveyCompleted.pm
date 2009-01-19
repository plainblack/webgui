package WebGUI::Flux::Operand::SurveyCompleted;
use strict;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::SurveyCompleted

=head1 DESCRIPTION

Returns true/false depending on whether the given user has completed the specified Survey2 wobject 

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

=head2 evaluate

See WebGUI::Flux::Operand base class for more information.

=cut

sub evaluate {
    my ($self) = @_;

    my $surveyId = $self->args()->{surveyId};
    my $user = $self->rule()->evaluatingForUser();
    
    return $self->session->db->quickScalar('select isComplete from Survey_response where assetId=? and userId=?',
    [ $surveyId, $user->userId()]);
}

#-------------------------------------------------------------------

=head2 definition

See WebGUI::Flux::Operand base class for more information.

=cut

sub definition {
    return { args => { surveyId => 1 } };
}

1;
