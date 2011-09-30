package WebGUI::Workflow::Activity::NotifyAboutVersionTag;


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
use WebGUI::VersionTag;
use WebGUI::Inbox;
use WebGUI::Asset;

=head1 NAME

Package WebGUI::Workflow::Activity::NotifyAboutVersionTag

=head1 DESCRIPTION

Send a message to a user about a version tag. If this version tag contains only one asset, then a URL to that asset will be included in the message automatically.

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
			message => {
				fieldType=>"textarea",
				defaultValue => "",
				label=> $i18n->get("notify message"),
				hoverHelp => $i18n->get("notify message help")
				},
			templateId => {
				fieldType    =>"template",
				defaultValue => "lYhMheuuLROK_iNjaQuPKg",
                namespace    => 'NotifyAboutVersionTag',
				label        => $i18n->get("email template", 'Workflow_Activity_NotifyAboutVersionTag'),
				hoverHelp    => $i18n->get("email template help", 'Workflow_Activity_NotifyAboutVersionTag')
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
	my $urlOfSingleAsset = "";
	if ($versionTag->getAssetCount) {
		# if there's only one asset in the tag, we might as well give them a direct link to it
		my $asset = $versionTag->getAssets->[0];	
		$urlOfSingleAsset = $self->session->url->getSiteURL().$asset->getUrl("func=view;revision=".$asset->get("revisionDate"));
	}
    my $var = {
        message  => $self->get('message'),
        comments => $versionTag->get('comments'),
        url      => $urlOfSingleAsset,
    };
    my $template   = WebGUI::Asset->newByDynamicClass($self->session, $self->get('templateId'));
    my $message    = $template->process($var);
	my $properties = {
		status=>"completed",
		subject=>$versionTag->get("name"),
		message=>$message,
    };
	if ($self->get("who") eq "committer") {
		$properties->{userId} = $versionTag->get("committedBy");
	} elsif ($self->get("who") eq "creator") {
		$properties->{userId} = $versionTag->get("createdBy");
	} else {
		$properties->{groupId} = $versionTag->get("groupToUse");
	}
	$inbox->addMessage($properties);
	return $self->COMPLETE;
}




1;


