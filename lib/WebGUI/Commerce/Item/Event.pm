package WebGUI::Commerce::Item::Event;

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

=head1 NAME

Package WebGUI::Commerce::Item::Event

=head1 DESCRIPTION

Item plugin for events in the EventManagement system.  Allows events entered there
to be part of the Commerce system.

=cut

use strict;

our @ISA = qw(WebGUI::Commerce::Item);

#-------------------------------------------------------------------
sub available {
	return $_[0]->{_event}->{approved};
}

#-------------------------------------------------------------------
sub description {
	return $_[0]->{_event}->{description};
}

#-------------------------------------------------------------------
sub handler {
	my $self = shift;
	my $transactionId = shift;
	#mark all purchaseIds as paid
	my $counter = 0;
	while (1) {
		my $purchaseId;
		if ($purchaseId = $self->session->scratch->get("purchaseId".$counter)) {
			$self->session->db->setRow('EventManagementSystem_purchases', 'purchaseId', {'purchaseId'=>$purchaseId, 'transactionId'=>$transactionId}, $purchaseId);
			$self->session->scratch->delete("purchaseId".$counter);
			$counter++;
		}
		else { last; }
	}
}

#-------------------------------------------------------------------
sub id {
	return $_[0]->{_event}->{productId};
}

#-------------------------------------------------------------------
sub isRecurring {
	return 0;
}

#-------------------------------------------------------------------
sub name {
	return $_[0]->{_event}->{title};
}

#-------------------------------------------------------------------

=head2 new ( $session )

Overload default constructor to glue in information from the EMS.

=cut

sub new {
	my ($class, $session, $eventId, $eventData);
	$class = shift;
	$session = shift;
	$eventId = shift;

	my $eventData = $session->db->quickHashRef("select p.productId, p.title, p.description, p.price, e.approved
                   from EventManagementSystem_products as e, products as p
		   where p.productId = e.productId and p.productId=".$session->db->quote($eventId)); 	
	
	bless {_event => $eventData, _session => $session }, $class;
}

#-------------------------------------------------------------------
sub needsShipping {
	return 0;
}

#-------------------------------------------------------------------
sub price {
	return $_[0]->{_event}->{price};
}

#-------------------------------------------------------------------
sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------
sub type {
	return 'Event';
}

#-------------------------------------------------------------------
sub weight {
	return 0;
}

1;

