package WebGUI::Workflow::Activity::PurgeOldAssetRevisions;


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
use WebGUI::Asset;
use WebGUI::Exception;

=head1 NAME

Package WebGUI::Workflow::Activity::PurgeOldAssetRevisions

=head1 DESCRIPTION

Removes old asset revisions from the database.

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
	my $i18n = WebGUI::International->new($session, "Asset");
	push(@{$definition}, {
		name=>$i18n->get("purge old asset revisions"),
		properties=> {
			purgeAfter=>{
				fieldType=>"interval",
				defaultValue=>60*60*24*365,
				label=>$i18n->get("purge revision after"),
				hoverHelp=>$i18n->get("purge revision after help")
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
	my ($self, $nothing, $instance) = @_;
    my $session = $self->session;
    my $log = $session->log;

    # keep track of how much time it's taking
    my $start = time();

    # figure out if we left off somewhere
    my $lastRunVersion = $instance->getScratch("purgeOldAssetsLastRevisionDate");
    my $suspectDate = ($lastRunVersion > 0) ? $lastRunVersion : (time() - $self->get("purgeAfter"));

    # the query to find old revisions
    my $sth = $session->db->read("select assetData.assetId,asset.className,assetData.revisionDate from asset
        left join assetData on asset.assetId=assetData.assetId where assetData.revisionDate<? 
        order by assetData.revisionDate asc", [$suspectDate]);
    my $ttl = $self->getTTL;
    while (my ($id, $class, $version) = $sth->array) {

        # we never want to purge the current version
        if (WebGUI::Asset->getCurrentRevisionDate($session, $id) == $version) {
            next;
        }

        # instanciate and purge
        my $asset = eval { WebGUI::Asset->newById($session, $id, $version); };
        if (Exception::Class->caught()) {
            $log->error("Could not instanciate asset $id $class $version perhaps it is corrupt.")
        }
        else {
            if ($asset->getRevisionCount("approved") > 1) {
                $log->info("Purging revision $version for asset $id.");
                $asset->purgeRevision;
            }
        }

        # give up if we're taking too long
        if (time() - $start > $ttl) { 
            $log->info("Ran out of time, will pick up with revision $version when we start again."); 
            $instance->setScratch("purgeOldAssetsLastRevisionDate", $version);
            $sth->finish;
            return $self->WAITING(1);
        } 
    }
	return $self->COMPLETE;
}




1;


