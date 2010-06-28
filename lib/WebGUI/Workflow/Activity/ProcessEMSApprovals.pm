package WebGUI::Workflow::Activity::ProcessEMSApprovals;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::International;
use WebGUI::VersionTag;

=head1 NAME

Package WebGUI::Workflow::Activity::ProcessEMSApprovals

=head1 DESCRIPTION

Uses the settings in the help desk to determine whether the resolved tickets should be closed or not.

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
        my $i18n       = WebGUI::International->new( $session, "Asset_EMSSubmissionForm" );
	push(@{$definition}, {
		name       => $i18n->get("activity title approve submissions"),
		properties => {}
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
    my $root    = WebGUI::Asset->getRoot($session);
    # keep track of how much time it's taking
    my $start   = time;
    my $limit   = 2_500;
    my $timeLimit = 60;

    my $list = $root->getLineage( ['descendants'], {
                 includeOnlyClasses => ['WebGUI::Asset::EMSSubmissionForm'],
                 returnObjects      => 1,
             } );
    
    for my $emsForm ( @$list ) {
       my $whereClause = q{ submissionStatus='approved' };
       my $res = $emsForm->getLineage(['children'],{  returnObjects => 1,
	     joinClass => 'WebGUI::Asset::EMSSubmission',
	     includeOnlyClasses => ['WebGUI::Asset::EMSSubmission'],
	     whereClause => $whereClause,
             returnObjects      => 1,
	 } );
        for my $submission ( @$res ) {
	    my $properties = { className => 'WebGUI::Asset::Sku::EMSTicket' };
            for my $name ( qw{title description seatsAvailable price vendorId
                               synopsis location duration startDate sku relatedRibbons
                                relatedBadgeGroups eventMetaData shipsSeparately} ) {
		    $properties->{$name} = $submission->get($name);
            }
            $properties->{eventNumber} = $self->session->db->quickScalar(
                    "select max(eventNumber)+1
                       from EMSTicket left join asset using (assetId)
			 where parentId=?",[$emsForm->ems->getId]) || 0;
            my $newAsset = $emsForm->ems->addChild( $properties );
            if( $newAsset ) {
                     # TODO this should be addRevision
		$submission->update({ ticketId => $newAsset->getId, submissionStatus => 'created' });
		WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, { override => 1, allowComments => 0 });
	    } else {
                $submission->addComment($@) if $@;
		$submission->update({ submissionStatus => 'failed' });
	    }
	    $limit--;
	    last if ! $limit or time > $start + $timeLimit;
	}
    }
    return $self->WAITING(1) if ! $limit or time > $start + $timeLimit;
    return $self->COMPLETE;
}

1;


