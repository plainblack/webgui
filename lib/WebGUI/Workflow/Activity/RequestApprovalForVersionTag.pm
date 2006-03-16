package WebGUI::Workflow::Activity::RequestApprovalForVersionTag;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
			subject => {
				fieldType=>"text",
				defaultValue=>"",
				label=>$i18n->get("approval subject"),
				hoverHelp => $i18n->get("approval subject help")
				},
			message => {
				fieldType=>"textarea",
				defaultValue => "",
				label=> $i18n->get("approval message"),
				hoverHelp => $i18n->get("approval message help")
				},
			doOnDeny => {
				fieldType=>"workflow",
				defaultValue=>"pbwf",
				label=>$i18n->get("do on deny"),
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
	my $inbox = WebGUI::Inbox->new($self->session);
	if ($instance->getScratch("status") eq "") {
		my $message = $inbox->addMessage({
			subject=>$self->get("subject"),
			message=>join("\n\n",$self->get("message"),
				$self->session->url->page("op=manageRevisionsInTag;workflowInstanceId=".$instance->getId.";tagId=".$versionTag->getId),
				$versionTag->get('name'), $versionTag->get("comments")),
			groupId=>$self->get("groupToApprove")
			});
		$instance->setScratch("messageId",$message->getId);
		$instance->setScratch("status","notified");
		return $self->WAITING;
	} elsif ($instance->getScratch("status") eq "denied") {
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




1;


