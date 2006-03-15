package WebGUI::Workflow::Activity::NotifyAboutVersionTag;


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

Package WebGUI::Workflow::Activity::NotifyAboutVersionTag

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
		name=>$i18n->get("notify about version tag"),
		properties=> { 
			who => {
				fieldType=>"selectBox",
				defaultValue=>"committer",
				options => {
					"committer" => $i18n->get("tag committer"),
					"creator" => $i18n->get("tag creator"),
					"groupToUse" => $i18n->get("group to use")
					},
				label=>$i18n->get("who to notify"),
				hoverHelp=>$i18n->get("who to notify help")
				},
			subject => {
				fieldType=>"text",
				defaultValue=>"",
				label=>$i18n->get("notify subject"),
				hoverHelp => $i18n->get("notify subject help")
				},
			message => {
				fieldType=>"textarea",
				defaultValue => "",
				label=> $i18n->get("notify message"),
				hoverHelp => $i18n->get("notify message help")
				},
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
	my $inbox = WebGUI::Inbox->new($self->session);
	my $properties = {
		status=>"completed",
		subject=>$self->get("subject"),
		message=>$self->get("message")."\n\n".$versionTag->get("name")."\n\n".$versionTag->get("comments"),
		};	
	if ($self->get("who") eq "committer") {
		$properties->{userId} = $versionTag->get("committedBy");
	} elsif ($self->get("who") eq "creator") {
		$properties->{userId} = $versionTag->get("createdBy");
	} else {
		$properties->{groupId} = $versionTag->get("groupToUse");
	}
	$inbox->addMessage($properties);
	return 1;
}




1;


