package WebGUI::Workflow::Activity::AddUserToGroup;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::International;

=head1 NAME

Package WebGUI::Workflow::Activity::AddUserToGroup;

=head1 DESCRIPTION

This activity adds the user (the working object) to a specified group.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_AddUserToGroup");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			groupId => {
				fieldType=>"group",
				label=>$i18n->get("group"),
				defaultValue=>undef,
				excludeGroups=>[7,2,1],
				hoverHelp=>$i18n->get("group help")
				},
			expireOffset => {
				fieldType=>"interval",
				label=>$i18n->get("expire offset"),
				defaultValue=>60*60*24*365,
				hoverHelp=>$i18n->get("expire offset help")
				}
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my $user = shift;
	$user->addToGroups([$self->get("groupId")], $self->get("expireOffset"));
	return $self->COMPLETE;
}



1;


