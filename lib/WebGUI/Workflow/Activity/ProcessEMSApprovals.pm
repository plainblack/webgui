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
    my $timeLimit = 120;

    my $list = $root->getLineage( ['children'], { returnObjects => 1,
                 includeOnlyClasses => ['WebGUI::Asset::EMSSubmissionForm'],
             } );
    
    for my $emsf ( @$list ) {
       my whereClause = q{ ( submissionStatus='approved' }
       my $res = $emsf->getLineage(['children'],{ 
	     includeOnlyClasses => ['WebGUI::Asset::EMSSubmission'],
	     whereClause => $whereClause,
	 } );
        for my $submission ( @$res ) {
            my %properties = $submission->get;
            delete $properties{submissionId};
            delete $properties{submissionStatus};
            delete $properties{sendEmailOnChange};
            delete $properties{ticketId};
            my $ticketId = $emsf->ems->addChild(
                className => 'WebGUI::Asset::Sku::EMSTicket',
                %properties;
            );
            $submission->update({ ticketId => $ticketId });
	    $limit--;
	    return $self->WAITING(1) if ! $limit or time > $start + $timeLimit;
	}
    }
    return $self->COMPLETE;
}

sub execute {
	my $self    = shift;
    my $session = $self->session;
    my $root    = WebGUI::Asset->getRoot($session);
return $self->ERROR;
    
    my $sth     = $session->db->read("select assetId from asset where className='WebGUI::Asset::Wobject::HelpDesk'");
    while (my ($assetId) = $sth->array) {
        my $hd = WebGUI::Asset->new($session,$assetId,"WebGUI::Asset::Wobject::HelpDesk");
        next unless defined $hd;

        my $closeAfter = $hd->get("closeTicketsAfter");

        my $rules                      = {};
        $rules->{'joinClass'         } = "WebGUI::Asset::Ticket";
        $rules->{'whereClause'       } = qq{Ticket.ticketStatus = 'resolved' and (Ticket.resolvedDate + $closeAfter <= UNIX_TIMESTAMP(NOW()))};
        $rules->{'includeOnlyClasses'} = ['WebGUI::Asset::Ticket'];
        $rules->{'returnObjects'     } = 1;
        
        my $tickets = $hd->getLineage(['children'], $rules);
        foreach my $ticket (@{$tickets}) {
            $ticket->setStatus("closed");
        }   
    }
	return $self->COMPLETE;
}

1;


