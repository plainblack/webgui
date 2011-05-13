package WebGUI::Workflow::Activity::RequestApprovalForVersionTag;


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
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI::Inbox;
use WebGUI::International;
use WebGUI::User;

=head1 NAME

Package WebGUI::Workflow::Activity::RequestApprovalForVersionTag

=head1 DESCRIPTION

Ask someone for approval of a version tag. If they approve then the workflow 
continues. If not, it is cancelled.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 cleanup ( )

Override this activity to add a cleanup routine to be run if an instance
is deleted with this activity currently in a waiting state.  This is a stub
and will do nothing unless overridden.

=cut

sub cleanup {
	my $self     = shift;
	my $instance = shift;
    $self->setMessageCompleted($instance);
	return 1;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session, "VersionTag");
    push @{$definition}, {
        name        => $i18n->get("request approval for version tag"),
        properties  => { 
            groupToApprove => {
                fieldType       => "group",
                defaultValue    => ["4"],       # Content managers
                label           => $i18n->get("group to approve"),
                hoverHelp       => $i18n->get("group to approve help"),
            },
            message => {
                fieldType       => "textarea",
                defaultValue    => "",
                label           => $i18n->get("approval message"),
                hoverHelp       => $i18n->get("approval message help"),
            },
            doOnDeny => {
                fieldType       => "workflow",
                defaultValue    => "pbworkflow000000000006",    # Unlock version tag and notify owner 
                label           => $i18n->get("do on deny"),
                type            => "WebGUI::VersionTag",
                hoverHelp       => $i18n->get("do on deny help"),
                none            => 1,
                noneLabel       => $i18n->get('continue with workflow'),
            },
            doOnApprove => {
                fieldType       => "workflow",
                defaultValue    => "",          # Continue with workflow
                label           => $i18n->get("do on approve"),
                type            => "WebGUI::VersionTag",
                hoverHelp       => $i18n->get("do on approve help"),
                none            => 1,
                noneLabel       => $i18n->get('continue with workflow'),
            },
			templateId => {
				fieldType    =>"template",
				defaultValue => "lYhMheuuLROK_iNjaQuPKg",
                namespace    => 'NotifyAboutVersionTag',
				label        => $i18n->get("email template", 'Workflow_Activity_NotifyAboutVersionTag'),
				hoverHelp    => $i18n->get("email template help", 'Workflow_Activity_NotifyAboutVersionTag')
            },
        },
    };
    return $class->SUPER::definition($session,$definition);
}

#----------------------------------------------------------------------------

=head2 doOnApprove ( versionTag, instance )

Does what is necessary when the tag gets approved. C<versionTag> is the 
WebGUI::VersionTag we're working with. C<instance> is the workflow instance
we're a part of.

Returns the notification code to be given to SPECTRE.

=cut

sub doOnApprove {
    my $self        = shift;
    my $versionTag  = shift;
    my $instance    = shift;

    # Make the new workflow, if necessary
    if ( $self->get("doOnApprove") ) {
        my $newInstance 
            = WebGUI::Workflow::Instance->create($self->session, {
                workflowId  => $self->get("doOnApprove"),
                methodName  => $instance->get("methodName"),
                className   => $instance->get("className"),
                parameters  => $instance->get("parameters"),
                priority    => $instance->get("priority"),
            })->start(1);
        $instance->delete;
    }
    
    # We're done here
    return $self->COMPLETE;
}

#----------------------------------------------------------------------------

=head2 doOnDeny ( versionTag, instance )

Does what is necessary when the tag gets denied. C<versionTag> is the 
WebGUI::VersionTag we're working with. C<instance> is the workflow instance
we're a part of.

Returns the notification code to be given to SPECTRE.

=cut

sub doOnDeny {
    my $self        = shift;
    my $versionTag  = shift;
    my $instance    = shift;

    # Make the new workflow, if necessary
    if ( $self->get("doOnDeny") ) {
        my $newInstance 
            = WebGUI::Workflow::Instance->create($self->session, {
                workflowId  => $self->get("doOnDeny"),
                methodName  => $instance->get("methodName"),
                className   => $instance->get("className"),
                parameters  => $instance->get("parameters"),
                priority    => $instance->get("priority"),
            })->start(1);
        $instance->delete;
    }
    
    # We're done here
    return $self->COMPLETE;
}


#----------------------------------------------------------------------------

=head2 execute ( versionTag, instance )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self        = shift;
    my $versionTag  = shift;
    my $instance    = shift;
    my $i18n        = WebGUI::International->new( $self->session, "VersionTag" );

    # First time through, send the message(s)
    if ( $instance->getScratch("status") eq "" ) {
        my $committedBy     = WebGUI::User->new( $self->session, $versionTag->get("committedBy") );
        my $groupIds        = $self->getGroupToApprove;

        # If user is in an approval group, they're auto-approved
        for my $groupId ( @{ $groupIds } ) {
            if ( $committedBy->isInGroup( $groupId ) ) {
                return $self->doOnApprove( $versionTag, $instance );
            } 
        }

        # If not yet approved, send out the message
        $self->sendMessage( $versionTag, $instance );

        # Update approval status
        $instance->setScratch( "status", "notified" );
        
        return $self->WAITING(60*20);
    } 
    # Second and subsequent times, check status
    # Tag is denied
    elsif ( $instance->getScratch("status") eq "denied" ) {
        # Clean up after ourselves
        $self->setMessageCompleted( $instance );
        $instance->deleteScratch( "status" );
        
        # We're done here
        return $self->doOnDeny( $versionTag, $instance );
    } 
    # Tag is approved
    elsif ( $instance->getScratch("status") eq "approved" ) {
        # Clean up after ourselves
        if (! $self->setMessageCompleted( $instance ) ) {
            return $self->ERROR;
        }
        $instance->deleteScratch( "status" );
        
        # We're done here
        return $self->doOnApprove( $versionTag, $instance );
    }

    # If we haven't done anything, spin the wheel again
    return $self->WAITING(60*60);
}

#----------------------------------------------------------------------------

=head2 getGroupToApprove ( versionTag, instance )

Returns an array reference of group IDs that could approve this tag. Only 
ONE of the members of these group(s) needs to approve the version tag to 
make it past this activity.

C<versionTag> is the version tag we're working with. C<instance> is the 
workflow instance we're part of

=cut

sub getGroupToApprove {
    my $self        = shift;
    return [ $self->get('groupToApprove') ];
}

#----------------------------------------------------------------------------

=head2 sendMessage ( versionTag, instance )

Send out approval messages to the necessary groups. Keep track of the 
message IDs so that we can refer to them later.

=cut

sub sendMessage {
    my $self            = shift;
    my $versionTag      = shift;
    my $instance        = shift;
    my $inbox           = WebGUI::Inbox->new( $self->session );
    my $i18n            = WebGUI::International->new( $self->session, "VersionTag" );
    my $messageIds      = $instance->getScratch( "messageId" );

    # FIXME: Do we need the workflowInstanceId here? See the check for 
    # it in WebGUI::Operation::VersionTag sub www_manageRevisionsInTag

    my $approvalUrl
        = $self->session->url->getSiteURL
        . $self->session->url->page(
            "op=manageRevisionsInTag;workflowInstanceId=" . $instance->getId
            . ";tagId=" . $versionTag->getId
        );
    my $var = {
        message  => $self->get('message'),
        comments => $versionTag->get('comments'),
        url      => $approvalUrl,
    };
    my $template     = WebGUI::Asset->newById($self->session, $self->get('templateId'));
    my $messageText  = $template->process($var);
    for my $groupId ( @{ $self->getGroupToApprove } ) {
        my $message 
            = $inbox->addMessage({
                subject => $i18n->get("approve/deny") . ": " . $versionTag->get("name"),
                message => $messageText,
                groupId => $groupId,
                status  => 'pending',
            });
        $messageIds = $messageIds ? join(",", $messageIds, $message->getId) : $message->getId;
    }

    # Keep track of message Ids so we can complete them 
    $instance->setScratch( "messageId", $messageIds );

    return;
}

#----------------------------------------------------------------------------

=head2 setApproved ( instance )

Marks this approved so that the workflow engine knows it can continue on as 
approved.

=head3 instance

A reference to the instance that you wish to set this approved.

=cut

sub setApproved {
    my $self        = shift;
    my $instance    = shift;
    $instance->setScratch( "status", "approved" );
    $instance->set({});  ##Bump spectre to get it to run right now.
}	

#----------------------------------------------------------------------------

=head2 setDenied ( instance )

Marks this approved so that the workflow engine knows it can continue on as 
denied.

=head3 instance

A reference to the instance that you wish to set this denied.

=cut

sub setDenied {
    my $self        = shift;
    my $instance    = shift;
    $instance->setScratch( "status", "denied" );
    $instance->set({});  ##Bump spectre to get it to run right now.
}

#----------------------------------------------------------------------------

=head2 setMessageCompleted ( instance )

Sets all the messages sent by this activity to completed. C<instance> is the
workflow instance we're part of.

=cut

sub setMessageCompleted {
    my $self     = shift;
    my $instance = shift;
    my $inbox    = WebGUI::Inbox->new( $self->session );

    # Set all messages to completed
    for my $messageId ( split /,/, $instance->getScratch("messageId") ) {
        if ($messageId) {
            my $message = $inbox->getMessage($messageId);
            if ($message) {
                $message->setCompleted;
            }
            else {
                $self->session->log->error("Could not get inbox message for messageId: $messageId");
                return 0;
            }
        }
        else {
            $self->session->log->error("Malformed workflow instance scratch variable messageId for instance: ". $instance->getId);
            return 0;
        }
    } ## end for my $messageId ( split...)

    $instance->deleteScratch("messageId");

    return 1;
} ## end sub setMessageCompleted

1;

