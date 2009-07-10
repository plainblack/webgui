package WebGUI::Workflow::Activity::TrashExpiredEvents;


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
use WebGUI::Asset::Event;

=head1 NAME

Package WebGUI::Workflow::Activity::TrashExpiredEvents

=head1 DESCRIPTION

Any events that are past a certain interval will be trashed.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_TrashExpiredEvents");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			trashAfter  => {
				fieldType=>"interval",
				label=>$i18n->get("trash after"),
				defaultValue=>60*60*24*30,
				hoverHelp=>$i18n->get("trash after help")
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
	my $sth = $self->session->db->read("select assetId from EventsCalendar_event where eventEndDate < ?", [time()-$self->get("trashAfter")]);
        while (my ($id) = $sth->array) {
                my $asset = WebGUI::Asset::Event->new($self->session, $id);
		if (defined $asset && $asset->get("eventEndDate") < time()-$self->get("trashAfter")) {
			$asset->trash;
		}	
        }
        $sth->finish;
	return $self->COMPLETE;
}



1;


