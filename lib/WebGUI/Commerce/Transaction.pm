package WebGUI::Commerce::Transaction;

use strict;
use WebGUI::Session;
use WebGUI::Id;
use WebGUI::SQL;
use WebGUI::Commerce::Payment;

#-------------------------------------------------------------------
sub addItem {
	my ($self, $item, $quantity);
	$self = shift;
	$item = shift;
	$quantity = shift;
	
	WebGUI::SQL->write("insert into transactionItem ".
		"(transactionId, itemName, amount, quantity, itemId, itemType) values ".
		"(".quote($self->{_transactionId}).",".quote($item->name).",".quote($item->price).",".quote($quantity).",".
		quote($item->id).",".quote($item->type).")");
	# Adjust total amount in the transaction table.
	WebGUI::SQL->write("update transaction set amount=amount+".($item->price * $quantity)." where transactionId=".quote($self->{_transactionId}));
	$self->{_properties}{amount} += ($item->price * $quantity);
	push @{$self->{_items}}, {
		transactionId	=> $self->{_transactionId},
		itemName	=> $item->name,
		amount		=> $item->price,
		quantity	=> $quantity,
		itemId		=> $item->id,
		itemType	=> $item->type,
	}
}

#-------------------------------------------------------------------
sub cancelTransaction {
	my ($self, $item, $plugin);
	$self = shift;

	return "Not a recurring transaction" unless ($self->isRecurring);
	
	# Recurring transactions can only have one item, so our items must be the first
	$item = $self->getItems->[0];

	$plugin = WebGUI::Commerce::Payment->load($self->gateway);
	$plugin->cancelRecurringPayment({
		id => $self->gatewayId
		});
	return $plugin->resultMessage.' (code: '.$plugin->errorCode.')' if ($plugin->errorCode);

	$self->status('Canceled');

	return undef;
}

#-------------------------------------------------------------------
sub completeTransaction {
	my ($self, $item);
	$self = shift;

	foreach (@{$self->getItems}) {
		$item = WebGUI::Commerce::Item->new($_->{itemId}, $_->{itemType});
		$item->handler;
	}

	$self->status('Completed');	
}

#-------------------------------------------------------------------
sub delete {
	my ($self) = shift;

	WebGUI::SQL->write("delete from transaction where transactionId=".quote($self->{_transactionId}));
	WebGUI::SQL->write("delete from transactionItem where transactionId=".quote($self->{_transactionId}));

	undef $self;
}

#-------------------------------------------------------------------
sub gateway {
	my ($self, $gateway);
	$self = shift;
	$gateway = shift;

	if ($gateway) {
		$self->{_properties}{gateway} = $gateway;
		WebGUI::SQL->write("update transaction set gateway=".quote($gateway)." where transactionId=".quote($self->{_transactionId}));
	}

	return $self->{_properties}{gateway};
}

#-------------------------------------------------------------------
sub gatewayId {
	my ($self, $gatewayId);
	$self = shift;
	$gatewayId = shift;

	if ($gatewayId) {
		$self->{_properties}{gatewayId} = $gatewayId;
		WebGUI::SQL->write("update transaction set gatewayId=".quote($gatewayId)." where transactionId=".quote($self->{_transactionId}));
	}

	return $self->{_properties}{gatewayId};
}

#-------------------------------------------------------------------
sub get {
	my ($self, $key);
	$self = shift;
	$key = shift;
	
	return $self->{_properties}{$key} if ($key);
	return $self->{_properties};
}

#-------------------------------------------------------------------
sub getItems {
	my ($self);
	$self = shift;
	
	return $self->{_items};
}

#-------------------------------------------------------------------
sub isRecurring {
	my ($self, $recurring);
	$self = shift;
	$recurring = shift;
	
	if (defined $recurring) {
		$self->{_properties}{recurring} = $recurring;
		WebGUI::SQL->write("update transaction set recurring=".quote($recurring)." where transactionId=".quote($self->{_transactionId}));
	}
	
	return $self->{_properties}{recurring};
}

#-------------------------------------------------------------------
sub lastPayedTerm {
	my ($self, $lastPayedTerm);
	$self = shift;
	$lastPayedTerm = shift;
	
	if (defined $lastPayedTerm) {
		$self->{_properties}{lastPayedTerm} = $lastPayedTerm;
		WebGUI::SQL->write("update transaction set lastPayedTerm=".quote($lastPayedTerm)." where transactionId=".quote($self->{_transactionId}));
	}
	
	return $self->{_properties}{lastPayedTerm};
}

#-------------------------------------------------------------------
sub new {
	my ($class, $transactionId, $gatewayId, $userId, $properties, $sth, $row, @items);
	
	$class = shift;
	$transactionId = shift;
	$gatewayId = shift;
	$userId = shift || $session{user}{userId};
	
	if ($transactionId eq 'new') {
		$transactionId = WebGUI::Id::generate;

		WebGUI::SQL->write("insert into transaction ".
			"(transactionId, userId, amount, gatewayId, initDate, completionDate, status) values ".
			"(".quote($transactionId).",".quote($userId).",0,".quote($gatewayId).",".quote(time).",NULL,'Pending')");
	}

	$properties = WebGUI::SQL->quickHashRef("select * from transaction where transactionId=".quote($transactionId));
	$sth = WebGUI::SQL->read("select * from transactionItem where transactionId=".quote($transactionId));
	while ($row = $sth->hashRef) {
		push(@items, $row);
	}

	bless {_transactionId => $transactionId, _properties => $properties, _items => \@items}, $class;
}

#-------------------------------------------------------------------
sub pendingTransactions {
	my (@transactionIds, @transactions);
	@transactionIds = WebGUI::SQL->buildArray("select transactionId from transaction where status = 'Pending'");

	foreach (@transactionIds) {
		push(@transactions, WebGUI::Commerce::Transaction->new($_));
	}

	return \@transactions;
}

#-------------------------------------------------------------------
sub status {
	my ($self, $status);
	$self = shift;
	$status = shift;

	if ($status) {
		$self->{_properties}{status} = $status;
		WebGUI::SQL->write("update transaction set status=".quote($status)." where transactionId=".quote($self->{_transactionId}));
	}

	return $self->{_properties}{status};
}

#-------------------------------------------------------------------
sub transactionId {
	my $self = shift;
	return $self->{_transactionId};
}

#-------------------------------------------------------------------
sub transactionsByUser {
	my ($self, @transactionIds, @transactions, $userId);
	my $self = shift;
	my $userId = shift;

	@transactionIds = WebGUI::SQL->buildArray("select transactionId from transaction where userId =".quote($userId));
	foreach (@transactionIds) {
		push (@transactions, WebGUI::Commerce::Transaction->new($_));
	}

	return \@transactions;
}
	
1;

