package WebGUI::Commerce::Transaction;

use strict;
use WebGUI::Session;
use WebGUI::Id;
use WebGUI::SQL;
use WebGUI::Commerce::Payment;

#-------------------------------------------------------------------

=head2 addItem ( item, quantity )

Add's an item to the transaction.

=head3 item

An WebGUI::Commerce::Item object of the item you want to add.

=head3 quantity

The number of items that are tobe added.

=cut

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

=head2 cancelTransaction

Cancels a recurring transaction. This is done by trying to cancel the subscription at the gateway
using a Payment plugin. If this is succesfull the transaction is marked as canceled.

=cut

sub cancelTransaction {
	my ($self, $item, $plugin);
	$self = shift;

	return "Not a recurring transaction" unless ($self->isRecurring);
	
	# Recurring transactions can only have one item, so our items must be the first
	$item = $self->getItems->[0];

	$plugin = WebGUI::Commerce::Payment->load($self->gateway);
	$plugin->cancelRecurringPayment({
		id => $self->gatewayId,
		transaction => $self,
		});
	return $plugin->resultMessage.' (code: '.$plugin->errorCode.')' if ($plugin->errorCode);

	$self->status('Canceled');

	return undef;
}

#-------------------------------------------------------------------

=head2 completeTransaction

Sets the status of a transaction to 'Completed' and executes the handler for every item attached to
the transction.

=cut

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

=head2 delete

Deletes the transaction from the database;

=cut

sub delete {
	my ($self) = shift;

	WebGUI::SQL->write("delete from transaction where transactionId=".quote($self->{_transactionId}));
	WebGUI::SQL->write("delete from transactionItem where transactionId=".quote($self->{_transactionId}));

	undef $self;
}

#-------------------------------------------------------------------

=head2 gateway ( gatewayName )

Returns the gateway connected to the transaction. If gatewayName is given the gateway property is set to that.

=head3 gatewayName

The name to which to set the gateway.

=cut

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

=head2 gatewayId ( id )

Returns the gateway ID of the transaction. If id is given the gateway ID is set to it.

=head3 id

The ID which to set the gatewayId to.

=cut

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

=head2 get ( property )

Returns the property requested. If no property is specified this method returns a hashref
containing all properties.

=head3 property

The name of the property you want.

=cut

sub get {
	my ($self, $key);
	$self = shift;
	$key = shift;
	
	return $self->{_properties}{$key} if ($key);
	return $self->{_properties};
}

#-------------------------------------------------------------------

=head2 getByGatewayId ( id, gateway )

Constructor. Return a transaction object that is identified by the given id and payment gateway.
Returns undef if no match is found.

=head3 id

The gateway ID of the transaction.

=head3 gateway

The payment gateway which the transaction is tied to.

=cut

sub getByGatewayId {
	my ($self, $gatewayId, $paymentGateway, $transactionId);
	$self = shift;
	$gatewayId = shift;
	$paymentGateway = shift;

	($transactionId) = WebGUI::SQL->quickArray("select transaction Id from transaction where gatewayId=".quote($gatewayId).
		" and gateway=".quote($paymentGateway));

	return WebGUI::Commerce::Transaction->new($transactionId) if $transactionId;
	return undef;
}

#-------------------------------------------------------------------

=head2 getItems

=cut

sub getItems {
	my ($self);
	$self = shift;
	
	return $self->{_items};
}

#-------------------------------------------------------------------

=head2 isRecurring ( recurring )

Returns a boolean indcating whether the transaction is recurring. If recurring is given, the isRecurring flag
will be set to it.

=head3 recurring

A boolean which sets the transaction as recurring if true.

=cut

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

=head2 lastPayedTerm ( term )

Returns the last term number that has been paid. If term is given this number will be set to it.

-head3 term

The number which to set tha last payed term to.

=cut

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

=head2 new ( transactionId, [ gateway, [ userId ] ] )

Constructor. Returns a transaction object. If transactionId is set to 'new' a new transaction is created.

=head3 transactionId

The transaction ID of the transaction you want. Set to 'new' for a new transaction.

=head3 gateway

The payment gateway to use for this transaction. Only needed for new transactions.

=head3 userId

The userId of the user for whom to create this transaction. Defaults to the current user. Only optional for
new transactions.

=cut

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

=head2 pendingTransactions

Returns a reference to an array which contains transaction objects of all pending transactions.

=cut

sub pendingTransactions {
	my (@transactionIds, @transactions);
	@transactionIds = WebGUI::SQL->buildArray("select transactionId from transaction where status = 'Pending'");

	foreach (@transactionIds) {
		push(@transactions, WebGUI::Commerce::Transaction->new($_));
	}

	return \@transactions;
}

#-------------------------------------------------------------------

=head2 status ( status )

Returns the status of the transaction. If status is given the transaction status will be set to it.

=head3 status

The value to set the transaction status to.

=cut

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

=head2 transactionId

Returns the transactionId of the transaction.

=cut

sub transactionId {
	my $self = shift;
	return $self->{_transactionId};
}

#-------------------------------------------------------------------

=head2 transactionsByUser ( userId )

Returns a reference to an array containing transaction objects of all tranactions by the user corresponding to userId.

=head3 userId

The ID of the user you want the transaction of.

=cut

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

