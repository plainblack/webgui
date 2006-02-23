package WebGUI::Workflow::Activity::ArchiveOldPosts;


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

=head1 NAME

Package WebGUI::Workflow::Activity::ArchiveOldPosts

=head1 DESCRIPTION

Uses the settings in the collaboration systems to determine whether the posts in those collaboration systems should be archived.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_ArchiveOldPosts");
	push(@{$definition}, {
		name=>$i18n->get("topicName"),
		properties=> {}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
        my $epoch = $self->session->datetime->time();
        my $a = $self->session->db->read("select assetId from asset where className='WebGUI::Asset::Wobject::Collaboration'");
        while (my ($assetId) = $a->array) {
                my $cs = WebGUI::Asset::Wobject::Collaboration->new($assetId);
                my $archiveDate = $epoch - $cs->get("archiveAfter");
                my $sql = "select asset.assetId, assetData.revisionDate from Post left join asset on asset.assetId=Post.assetId 
                        left join assetData on Post.assetId=assetData.assetId and Post.revisionDate=assetData.revisionDate
                        where Post.dateUpdated<? and assetData.status='approved' and asset.state='published'
                        and asset.lineage like ?";
                my $b = $self->session->db->read($sql,[$archiveDate, $cs->get("lineage").'%']);
                while (my ($id, $version) = $b->array) {
                        my $post = WebGUI::Asset::Post->new($id,undef,$version);
                        $post->setStatusArchived if (defined $post && $post->get("dateUpdated") < $archiveDate);
                }
                $b->finish;
        }
        $a->finish;
}

1;


