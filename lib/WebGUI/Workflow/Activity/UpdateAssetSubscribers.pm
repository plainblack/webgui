package WebGUI::Workflow::Activity::UpdateAssetSubscribers;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::User;
use WebGUI::Group;

=head1 NAME

Package WebGUI::Workflow::Activity::UpdateCollaborationSubscribers

=head1 DESCRIPTION

This workflow activity should be called whenever permissions to view a Collaboration System
are changed.  It will remove users who are no longer able to view the CS.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session, "Workflow_Activity_UpdateAssetSubscribers");
    push(@{$definition}, {
        name       => $i18n->get("name"),
        properties => { }
    });
    return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self  = shift;
    my $asset = shift;
    my $session = $self->session;

    return unless $asset->get('subscriptionGroupId');

    my $expireTime = time() + $self->getTTL();
    my $subscriptionGroup = WebGUI::Group->new($session, $asset->get('subscriptionGroupId'));

    ##Deserialize from scratch
    if (! $subscriptionGroup) {
        $session->log->warn("Subscription group is missing for assetId: ".$asset->getId);
        return $self->COMPLETE;
    }
    my @users = @{ $subscriptionGroup->getUsers }; ##Cache
    my @usersToDelete = (); ##Cache
    ##Note, we could use grep here, but we can't interrupt if the workflow runs too long
    USER: foreach my $userId (@users) {
        if (time() > $expireTime) {
            #return $self->WAITING(1);
        }
        next USER if $asset->canView($userId);
        push @usersToDelete, $userId;
    }
    if (@usersToDelete) {
        $subscriptionGroup->deleteUsers(\@usersToDelete);
    }
    #Clear scratch
    return $self->COMPLETE;
}



1;
