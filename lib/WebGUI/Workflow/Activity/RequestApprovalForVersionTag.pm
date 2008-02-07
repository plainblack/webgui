package WebGUI::Workflow::Activity::RequestApprovalForVersionTag;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::VersionTag;
use WebGUI::Inbox;
use WebGUI::International;
use WebGUI::User;

=head1 NAME

Package WebGUI::Workflow::Activity::RequestApprovalForVersionTag

=head1 DESCRIPTION

Ask someone for approval of a version tag. If they approve then the workflow continues. If not, it is cancelled.

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
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "VersionTag");
	push(@{$definition}, {
		name=>$i18n->get("request approval for version tag"),
		properties=> { 
			groupToApprove => {
				fieldType=>"group",
				defaultValue=>["4"],
				label=>$i18n->get("group to approve"),
				hoverHelp=>$i18n->get("group to approve help")
				},
			message => {
				fieldType=>"textarea",
				defaultValue => "",
				label=> $i18n->get("approval message"),
				hoverHelp => $i18n->get("approval message help")
				},
			doOnDeny => {
				fieldType=>"workflow",
				defaultValue=>"pbworkflow000000000006",
				label=>$i18n->get("do on deny"),
				type=>"WebGUI::VersionTag",
				hoverHelp => $i18n->get("do on deny help")
				}
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my $versionTag = shift;
	my $instance = shift;
	my $i18n = WebGUI::International->new($self->session, "VersionTag");
	my $inbox = WebGUI::Inbox->new($self->session);
	if ($instance->getScratch("status") eq "") {
		my $u = WebGUI::User->new($self->session, $versionTag->get("committedBy"));
		if ($u->isInGroup($self->get("groupToApprove"))) {
			return $self->COMPLETE;
 		} else {
			my $message = $inbox->addMessage({
				subject=>$i18n->get("approve/deny").": ".$versionTag->get("name"),
				message=>join("\n\n",$self->get("message"),
					$self->session->url->getSiteURL().$self->session->url->page("op=manageRevisionsInTag;workflowInstanceId=".$instance->getId.";tagId=".$versionTag->getId),
					$versionTag->get("comments")),
				groupId=>$self->get("groupToApprove"),
				status=>'pending'
				});
			$instance->setScratch("status","notified");
			$instance->setScratch("messageId",$message->getId);
			return $self->WAITING;
 		}
	} elsif ($instance->getScratch("status") eq "denied") {
		my $message = $inbox->getMessage($instance->getScratch("messageId"));
		$message->setCompleted;
		my $newInstance = WebGUI::Workflow::Instance->create($self->session, {
			workflowId=>$self->get("doOnDeny"),
			methodName=>$instance->get("methodName"),
			className=>$instance->get("className"),
			parameters=>$instance->get("parameters"),
			priority=>$instance->get("priority")
			});
		$instance->delete;
		return $self->COMPLETE;
	} elsif ($instance->getScratch("status") eq "approved") {
		my $message = $inbox->getMessage($instance->getScratch("messageId"));
		$message->setCompleted;
		$instance->deleteScratch("messageId");
		$instance->deleteScratch("status");
		return $self->COMPLETE;
	}
	return $self->WAITING;
}


#-------------------------------------------------------------------

=head2 setApproved ( insstance )

Marks this approved so that the workflow engine knows it can continue on as approved.

=head3 instance

A reference to the instance that you wish to set this approved.

=cut

sub setApproved {
	my $self = shift;
	my $instance = shift;
	$instance->setScratch("status","approved");
}	

#-------------------------------------------------------------------

=head2 setDenied ( insstance )

Marks this approved so that the workflow engine knows it can continue on as denied.

=head3 instance

A reference to the instance that you wish to set this denied.

=cut

sub setDenied {
	my $self = shift;
	my $instance = shift;
	$instance->setScratch("status","denied");
}	


1;


