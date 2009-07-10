package WebGUI::Workflow::Activity::ArchiveOldThreads;


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
use WebGUI::Asset;

=head1 NAME

Package WebGUI::Workflow::Activity::ArchiveOldThreads

=head1 DESCRIPTION

Uses the settings in the collaboration systems to determine whether the threads in those collaboration systems should be archived.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_ArchiveOldThreads");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
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
                my $cs = WebGUI::Asset->new($self->session, $assetId, "WebGUI::Asset::Wobject::Collaboration");
		next unless defined $cs;
                next unless $cs->get("archiveEnabled");
                my $archiveDate = $epoch - $cs->get("archiveAfter");
                my $sql = "select asset.assetId, assetData.revisionDate from Post left join asset on asset.assetId=Post.assetId 
                        left join assetData on Post.assetId=assetData.assetId and Post.revisionDate=assetData.revisionDate
                        where Post.revisionDate<? and assetData.status='approved' and asset.state='published'
			and Post.threadId=Post.assetId and asset.lineage like ?";
                my $b = $self->session->db->read($sql,[$archiveDate, $cs->get("lineage").'%']);
                while (my ($id, $version) = $b->array) {
			my $thread = WebGUI::Asset->new($self->session, $id, "WebGUI::Asset::Post::Thread", $version);
			my $archiveIt = 1;
			foreach my $post (@{$thread->getPosts}) {
                        	$archiveIt = 0 if (defined $post && $post->get("revisionDate") > $archiveDate);
			}
			$thread->archive if ($archiveIt);
                }
                $b->finish;
        }
        $a->finish;
	return $self->COMPLETE;
}

1;


