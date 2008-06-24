package WebGUI::Workflow::Activity::CheckFluxRules;

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::Flux;
use WebGUI::Group;

=head1 NAME

Package WebGUI::Workflow::Activity::CheckFluxRules

=head1 DESCRIPTION

This activity loops through all users in the specified group and evaluates 
every Flux rule against each user (as an "indirect" check, as opposed to "direct access"
when a user tries to view a wobject protected by a Rule). You would want to run this
Workflow on a regular schedule if you have time-based Flux Rules and you want the website 
to automatically 'notice' when a Rule becomes true (e.g. and hence have pre-wired Workflows
triggered)

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    push(
        @{$definition},
        {   name       => 'CheckFluxRules',
            properties => {
                groupId => {
                    fieldType    => "group",
                    label        => 'Group',
                    defaultValue => 2, # Registered Users
                    hoverHelp    => 'All users in this group will be checked against all Flux Rules',
                }
            }
        }
    );
    return $class->SUPER::definition( $session, $definition );
}

#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self = shift;

    my $groupId = $self->get('groupId');
    my $group = WebGUI::Group->new( $self->session(), $groupId );

    return $self->ERROR
        if !$group;    # Could not instantiate Group from groupId

    my @users = map {WebGUI::User->new($self->session, $_)} @{ $group->getAllUsers() };

    return $self->COMPLETE
        if !@users;    # No users to process

    foreach my $rule ( @{ WebGUI::Flux->getRules( $self->session() ) } ) {
        foreach my $user (@users) {
            # Eval Rule repeatedly, once per user, so that Rule object can (in the future)
            # be smart and return a cached result if it's user-independent 
            $rule->evaluateFor(
                {   user     => $user,
                    indirect => 1
                }
            );
        }
    }
    return $self->COMPLETE;
}
1;

