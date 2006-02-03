package WebGUI::Commerce::Item::Event;

use strict;

our @ISA = qw(WebGUI::Commerce::Item);

#-------------------------------------------------------------------
sub available {
	return $_[0]->{_event}->{available};
}

#-------------------------------------------------------------------
sub description {
	return $_[0]->{_event}{description};
}

#-------------------------------------------------------------------
sub id {
	return $_[0]->{_event}{productId};
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
sub new {
	my ($class, $session, $eventId, $eventData);
	$class = shift;
	$session = shift;
	$eventId = shift;

	my $eventData = $session->db->quickHashRef("select p.productId, p.title, p.description, p.price, e.available
                   from EventManagementSystem_products as e, products as p
		   where p.productId = e.productId and p.productId=".$session->db->quote($eventId)); 	
	
	bless {_event => $eventData}, $class;
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
sub type {
	return 'Event';
}

#-------------------------------------------------------------------
sub weight {
	return 0;
}

1;

