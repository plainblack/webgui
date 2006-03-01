package WebGUI::Workflow::Activity::PurgeOldAssetRevisions;


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
use WebGUI::Asset;

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

See WebGUI::Workflow::Activity::defintion() for details.

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
	my $self = shift;
        my $sth = $self->session->db->read("select assetData.assetId,asset.className,assetData.revisionDate from asset left join assetData on asset.assetId=assetData.assetId where assetData.revisionDate<? order by assetData.revisionDate asc", [time() - $self->get("purgeAfter")]);
        while (my ($id, $class, $version) = $sth->array) {
        	my $asset = WebGUI::Asset->new($self->session, $id,$class,$version);
                if ($asset->getRevisionCount("approved") > 1) {
                	$asset->purgeRevision;
                }
        }
	$sth->finish;
	return 1;
}




1;


