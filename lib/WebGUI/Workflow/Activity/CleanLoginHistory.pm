package WebGUI::Workflow::Activity::CleanLoginHistory;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

=head1 NAME

Package WebGUI::Workflow::Activity::CleanLoginHistory

=head1 DESCRIPTION

Deletes some of the old cruft from the userLoginLog table.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_CleanLoginHistory");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			ageToDelete => {
				fieldType=>"interval",
				label=>$i18n->get("age to delete"),
				defaultValue=>60 * 60 * 24 * 90,
				hoverHelp=>$i18n->get("age to delete help")
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
        $self->session->db->write("delete from userLoginLog where timeStamp < ?", [(time()-($self->get("ageToDelete")))]);
	return $self->COMPLETE;
}



1;


