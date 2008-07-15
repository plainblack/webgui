package WebGUI::Flux::Operand::SurveyCompleted;
use strict;
use warnings;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::SurveyCompleted

=head1 DESCRIPTION

Returns true/false depending on whether the given user has completed the specified SurveyCompleted 

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

sub evaluate {
    my ($self) = @_;

    my $surveyId = $self->args()->{surveyId};
    my $user = $self->rule()->evaluatingForUser();
    
    # This will probably need to change when Survey2 comes out..
    return $self->session->db->quickScalar('select isComplete from Survey_response where Survey_id=? and userId=?',
    [ $surveyId, $user->userId()]);
}

#-------------------------------------------------------------------

sub definition {
    return { args => { surveyId => 1 } };
}

1;
