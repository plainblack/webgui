package WebGUI::Workflow::Activity::TrashExpiredEvents;


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
    my $self       = shift;
    my $session    = $self->session;
    my $finishTime = time() + $self->getTTL;
    my $date = WebGUI::DateTime->new($session, time() - $self->get("trashAfter") );
    my $sth  = $session->db->read( "select Event.assetId, revisionDate from Event join assetData using (assetId, revisionDate) where endDate < ? and revisionDate = (select max(revisionDate) from assetData where assetData.assetId=Event.assetId);", [ $date->toDatabaseDate ]);
    EVENT: while ( my ($id) = $sth->array ) {
        my $asset = eval { WebGUI::Asset->newById($session, $id); };
        if (! Exception::Class->caught()) {
            $asset->trash;
        }
        last EVENT if time() > $finishTime;
    }
    $sth->finish;
    return $self->COMPLETE;
}



1;


