package WebGUI::Commerce::ShoppingCart;

use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Commerce::Item;
use WebGUI::Commerce::Payment;

#-------------------------------------------------------------------
sub add {
	my ($self, $itemId, $itemType, $quantity);
	$self = shift;
	$itemId = shift;
	$itemType = shift;
	$quantity = shift || 1;

	$self->{_items}{$itemId."_".$itemType} = {
		itemId		=> $itemId,
		itemType	=> $itemType,
		quantity	=> $self->{_items}{$itemId."_".$itemType}{quantity} + $quantity
		};
		
	WebGUI::SQL->write("delete from shoppingCart where sessionId=".quote($self->{_sessionId})." and itemId=".quote($itemId)." and itemType=".quote($itemType));
	WebGUI::SQL->write("insert into shoppingCart ".
		"(sessionId, itemId, itemType, quantity) values ".
		"(".quote($self->{_sessionId}).",".quote($itemId).",".quote($itemType).",".$self->{_items}{$itemId."_".$itemType}{quantity}.")");
}

#-------------------------------------------------------------------
sub empty {
	my ($self);
	$self = shift;
	
	WebGUI::SQL->write("delete from shoppingCart where sessionId=".quote($self->{_sessionId}));
}

#-------------------------------------------------------------------
sub getItems {
	my ($self, $periodResolve, %cartContent, $item, $properties, @recurring, @normal);
	$self = shift;
	
	$periodResolve = WebGUI::Commerce::Payment::recurringPeriodValues;
	%cartContent = %{$self->{_items}};
	foreach (values(%cartContent)) {
		$item = WebGUI::Commerce::Item->new($_->{itemId}, $_->{itemType});
		$properties = {
			quantity        => $_->{quantity},
			period          => lc($periodResolve->{$item->duration}),
			name		=> $item->name,
			price		=> sprintf('%.2f', $item->price),
			totalPrice	=> sprintf('%.2f', $item->price * $_->{quantity}),
			item		=> $item,
			};

		if ($item->isRecurring) {
			push(@recurring, $properties);
		} else {
			push(@normal, $properties);
		}
	}
	
	return (\@normal, \@recurring);
}

#-------------------------------------------------------------------
sub new {
	my ($class, $sessionId, $sth, $row, %items);
	$class = shift;
	$sessionId = shift || $session{var}{sessionId};

	$sth = WebGUI::SQL->read("select * from shoppingCart where sessionId=".quote($sessionId));
	while ($row = $sth->hashRef) {
		$items{$row->{itemId}."_".$row->{itemType}} = $row;
	}

	bless {_sessionId => $sessionId, _items => \%items}, $class;
}

1;
