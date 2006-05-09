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
use WebGUI::Utility;

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
	my ($class, $session, $eventId);
	$class = shift;
	$session = shift;
	$eventId = shift;

	my $eventData = $session->db->quickHashRef("select p.productId, p.title, p.description, p.price, e.approved, e.passId, e.passType
                   from EventManagementSystem_products as e, products as p
		   where p.productId = e.productId and p.productId=".$session->db->quote($eventId)); 	
	
	bless {_event => $eventData, _session => $session, priceLineItem => 1}, $class;
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
sub priceLineItem {
	my $self = shift;
	# this will become the total number of normally-priced events.
	my $quantity = shift;
	# this is the output of ShoppingCart->getItems (the \@normal arrayref).
	my $cartItems = shift;
	use Data::Dumper;
	# $self->session->errorHandler->warn('normal contents: '.Dumper($cartItems));
	# this is the default price of this event.
	my $price = $self->{_event}->{price};
	# get the list of discount passes that this event is "under"
	my @discountPasses = split(/::/,$self->{_event}->{passId});
	$self->session->errorHandler->warn('discount passes: '.Dumper(\@discountPasses));
	# return the default behavior if this event does not have a pass assigned.
	return ($price * $quantity) unless (scalar(@discountPasses) && ($self->{_event}->{passType} eq 'member'));
	# keep a running total of this line item.
	my $totalPrice = 0;
	# build the list of passes in our cart.
	my %passesInCart; # key: passId, value: quantity in cart
	my $totalPassesInCart;
	foreach my $passId (@discountPasses) {
		# get a list of events that define this pass
		my @passEvents = $self->session->db->buildArray("select productId from EventManagementSystem_products where passType='defines' and passId=?",[$passId]);
		$self->session->errorHandler->warn('pass events: '.Dumper(\@passEvents));
		my $numberOfPasses = 0;
		# find out if we have any of this pass's events in our cart.
		foreach my $item (@$cartItems) {
			$self->session->errorHandler->warn('quantity of this pass event: '.$item->{quantity});
			$numberOfPasses += $item->{quantity} if (
				$item->{item}->type eq 'Event'
				&& isIn($item->{item}->{_event}->{productId},@passEvents)
			);
		}
		if ($numberOfPasses) {
			$self->session->errorHandler->warn('adding a discount pass.');
			$passesInCart{$passId} = $numberOfPasses;
			$totalPassesInCart += $numberOfPasses;
		}
	}
	foreach my $passId (keys(%passesInCart)) {
		my $pass = $self->session->db->quickHashRef("select * from EventManagementSystem_discountPasses where passId=?",[$passId]);
		my $discountedPrice = $price;
		my $numberOfThisPass = $passesInCart{$passId};
		# calculate discount.
		if ($pass->{type} eq 'newPrice') {
			$discountedPrice = (0 + $pass->{amount}) if ($price > (0 + $pass->{amount}));
		} elsif ($pass->{type} eq 'amountOff') {
			# not yet implemented!
		} elsif ($pass->{type} eq 'percentOff') {
			# not yet implemented!
		}
		# while we still have passes and items left to discount.
		while ($numberOfThisPass && $quantity) {
			$self->session->errorHandler->warn('applying a discount pass.');
			$totalPrice += $discountedPrice;
			$quantity--;
			$numberOfThisPass--;
		}
	}
	# return the total of the discounted items plus the total of the non discounted items.
	return ($totalPrice + ($quantity * $price));
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

