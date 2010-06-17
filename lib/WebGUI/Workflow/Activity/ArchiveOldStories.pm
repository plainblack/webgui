package WebGUI::Workflow::Activity::ArchiveOldStories;


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
use WebGUI::Asset::Wobject::StoryArchive;

=head1 NAME

Package WebGUI::Workflow::Activity::ArchiveOldStories

=head1 DESCRIPTION

Uses the settings in the Story Archive to determine whether the Stories (and Folders) in those Story Archives should be archived.

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
    my $i18n = WebGUI::International->new($session, "Workflow_Activity_ArchiveOldStories");
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
    my $self    = shift;
    my $session = $self->session;
    my $epoch   = $self->session->datetime->time();
    my $getAnArchive = WebGUI::Asset::Wobject::StoryArchive->getIsa($session);
    ARCHIVE: while (my $archive = $getAnArchive->()) {
        next ARCHIVE unless $archive && $archive->get("archiveAfter");
        my $archiveDate = $epoch - $archive->get("archiveAfter");
        my $folders = $archive->getLineage(
            ['children'],
            {
                statusToInclude => ['approved'],
                whereClause     => 'creationDate < '.$session->db->quote($archiveDate),
                returnObjects   => 1,
            },
        );
        FOLDER: foreach my $folder (@{ $folders }) {
            next FOLDER unless $folder;
            my $stories = $folder->getLineage(
                ['children'], { returnObjects   => 1, },
            );
            STORY: foreach my $story (@{ $stories }) {
                next STORY unless $story;
                $story->update({ status => 'archived' });
            }
            $folder->update({ status => 'archived' });
        }
    }
    return $self->COMPLETE;
}

1;


