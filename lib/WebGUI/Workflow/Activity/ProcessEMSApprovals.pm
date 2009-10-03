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
	push(@{$definition}, {
		name       => "Process Approved EMS Submissions",  # TODO Internationalize
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
return $self->FAILED;
    
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


