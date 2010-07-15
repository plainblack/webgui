package WebGUI::Shop::TransactionItem;

use strict;

use Scalar::Util qw/blessed/;
use Moose;
use WebGUI::Definition;
use JSON qw{ to_json };

property assetId => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property configuredTitle => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property options => (
    is         => 'rw',
    noFormPost => 1,
    default    => '',
    default    => sub { return {}; },
    traits     => ['Hash', 'WebGUI::Definition::Meta::Property::Serialize',],
    isa        => 'WebGUI::Type::JSONHash',
    coerce     => 1,
);

property quantity => (
    is => 'rw',
    noFormPost => 1,
    default => 1,
);
property price => (
    is => 'rw',
    noFormPost => 1,
    default => 0,
);
property vendorId => (
    is => 'rw',
    noFormPost => 1,
    default => 'defaultvendor000000000',
);
property vendorPayoutAmount => (
    is => 'rw',
    noFormPost => 1,
    default => 0.00,
);
property vendorPayoutStatus => (
    is => 'rw',
    noFormPost => 1,
    default => 'NotPaid',
);
property shippingTrackingNumber => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property orderStatus => (
    is => 'rw',
    noFormPost => 1,
    default => 'NotShipped',
);
property shippingAddressId => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingName => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingAddress1 => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingAddress2 => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingAddress3 => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingCity => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingState => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingCountry => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingCode => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property shippingPhoneNumber => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property taxRate => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property taxConfiguration => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);

property lastUpdated => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);

has [ qw/transaction itemId/ ] => (
    is       => 'ro',
    required => 1,
);

has item => (
    is      => 'rw',
    trigger => \&_mine_item,
);

sub _mine_item {
    my ($self, $item) = @_;
    my $sku = $item->getSku;
    $self->options($sku->getOptions);
    $self->assetId($sku->getId);
    $self->price($sku->getPrice);
    $self->configuredTitle($item->get('configuredTitle'));
    $self->quantity($item->get('quantity'));
    $self->vendorId($sku->getVendorId);
    $self->vendorPayoutAmount(sprintf '%.2f', $sku->getVendorPayout * $item->get('quantity'));

    my $address = $item->getShippingAddress;
    $self->shippingAddressId($address->getId);
    $self->shippingName($address->name);
    $self->shippingAddress1($address->address1);
    $self->shippingAddress2($address->address2);
    $self->shippingAddress3($address->address3);
    $self->shippingCity($address->city);
    $self->shippingState($address->state);
    $self->shippingCountry($address->country);
    $self->shippingCode($address->code);
    $self->shippingPhoneNumber($address->phoneNumber);

    # Store tax rate for product
    my $transaction = $self->transaction;
    my $taxDriver = WebGUI::Shop::Tax->getDriver( $transaction->session );
    $self->taxRate($taxDriver->getTaxRate( $sku, $address ));
    $self->taxConfiguration(to_json( $taxDriver->getTransactionTaxData( $sku, $address ) || '{}' ));

    if (!$sku->isShippingRequired && $transaction->isSuccessful) {
        $self->orderStatus('Shipped');
    }
}

use WebGUI::DateTime;
use WebGUI::Exception::Shop;
use WebGUI::Shop::Transaction;
use WebGUI::Shop::Tax;

=head1 NAME

Package WebGUI::Shop::TransactionItem

=head1 DESCRIPTION

Each transaction item represents a sku that was purchased or attempted to be purchased.

=head1 SYNOPSIS

 use WebGUI::Shop::TransactionItem;

 my $item = WebGUI::Shop::TransactionItem->new($transaction);

=head1 METHODS

These subroutines are available from this package:

#-------------------------------------------------------------------

=head2 new ( transaction, itemId )

Constructor.  Instanciates a transaction item based upon itemId.

=head2 new ( properties )

Constructor.  Builds a new transaction item object.  The properties of the newly created object are not persisted
to the database.  The write method must be called on the object to do that.

=head2 new ( transaction, properties )

Constructor.  Builds a new transaction item object.  This form of new is
deprecated, and only exists for backwards compatibility with the old "create"
method.  The properties of the newly created object are not persisted to
the database.  The write method must be called on the object to do that.

=head3 transaction

A reference to the current transaction object.

=head3 itemId

The unique id of the item to instanciate.

=head3 properties

A hash reference that contains one of the following:

=head4 item

A reference to a WebGUI::Shop::CartItem. Alternatively you can manually pass in any of the following
fields that would be created automatically by this object: assetId configuredTitle options shippingAddressId
shippingName shippingAddress1 shippingAddress2 shippingAddress3 shippingCity shippingState shippingCountry
shippingCode shippingPhoneNumber quantity price vendorId

=head4 shippingTrackingNumber

A tracking number that is used by the shipping method for this transaction.

=head4 orderStatus

The status of this item. The default is 'NotShipped'. Other statuses include: Cancelled, Backordered, Shipped

=cut

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    if (ref $_[0] eq 'HASH') {
        my $properties = $_[0];
        my $transaction = $properties->{transaction};
        if (! (blessed $transaction && $transaction->isa("WebGUI::Shop::Transaction"))) {
            WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Shop::Transaction", got=>(ref $transaction), error=>"Need a transaction.");
        }
        my ($itemId)                 = $class->_init($transaction);
        $properties->{itemId}        = $itemId;
        $properties->{transactionId} = $transaction->getId;
        return $class->$orig($properties);
    }
    my $transaction = shift;
    if (! (blessed $transaction && $transaction->isa("WebGUI::Shop::Transaction"))) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Shop::Transaction", got=>(ref $transaction), error=>"Need a transaction.");
    }
    my $argument2 = shift;
    if (!defined $argument2) {
        WebGUI::Error::InvalidParam->throw( param=>$argument2, error=>"Need a itemId.");
    }
    if (ref $argument2 eq 'HASH') {
        ##Build a new one
        my ($itemId) = $class->_init($transaction);
        my $properties                = $argument2;
        $properties->{transaction}    = $transaction;
        $properties->{itemId}         = $itemId;
        return $class->$orig($properties);
    }
    else {
        ##Look up one in the db
        my $item = $transaction->session->db->quickHashRef("select * from transactionItem where itemId=?", [$argument2]);
        if ($item->{transactionId} eq "") {
            WebGUI::Error::ObjectNotFound->throw(error=>"Item not found", id=>$argument2);
        }
        if ($item->{transactionId} ne $transaction->getId) {
            WebGUI::Error::ObjectNotFound->throw(error=>"Item not in this transaction.", id=>$argument2);
        }
        $item->{transaction} = $transaction;
        return $class->$orig($item);
    }
};

#-------------------------------------------------------------------

=head2 _init ( session )

Builds a stub of object information in the database, and returns the newly created
transactionId, and the dateOfPurchase fields so the object can be initialized correctly.

=cut

sub _init {
    my $class       = shift;
    my $transaction = shift;
    my $session     = $transaction->session;
    my $itemId      = $session->id->generate;
    $session->db->write("insert into transactionItem (itemId, transactionId) values (?, ?)",[$itemId, $transaction->getId]);
    return ($itemId);
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this item from the transaction.

=cut

sub delete {
    my $self = shift;
    $self->transaction->session->db->deleteRow("transactionItem", "itemId", $self->getId);
    return undef;
}

#-------------------------------------------------------------------

=head2 getId () 

Returns the unique id of this item.

=cut

sub getId {
    my $self = shift;
    return $self->itemId;
}


#-------------------------------------------------------------------

=head2 getSku ( )

Returns an instanciated WebGUI::Asset::Sku object for this item.

=cut

sub getSku {
    my ($self) = @_;
    my $asset = eval { WebGUI::Asset->newById($self->transaction->session, $self->assetId); };
    if (Exception::Class->caught()) {
        WebGUI::Error::ObjectNotFound->throw(error=>'SKU Asset '.$self->assetId.' could not be instanciated. Perhaps it no longer exists.', id=>$self->assetId);
        return undef;
    }
    $asset->applyOptions($self->options);
    return $asset;
}

#-------------------------------------------------------------------

=head2 issueCredit ( )

Returns the money from this item to the user in the form of in-store credit.

=cut

sub issueCredit {
    my $self = shift;
    my $credit = WebGUI::Shop::Credit->new($self->transaction->session, $self->transaction->userId);
    $credit->adjust(($self->price * $self->quantity), "Issued credit on sku ".$self->assetId." for transaction item ".$self->getId." on transaction ".$self->transaction->getId);
    $self->getSku->onRefund($self);
    $self->update({orderStatus=>'Cancelled'});
}

#-------------------------------------------------------------------

=head2 newByDynamicTransaction ( session, itemId )

Constructor, but will dynamically find the approriate transaction and attach it to the item object.

=head3 session

A reference to the current session.

=head3 itemId

The unique id for this transaction item.

=cut

sub newByDynamicTransaction {
    my ($class, $session, $itemId) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    unless (defined $itemId) {
        WebGUI::Error::InvalidParam->throw(error=>"Need an itemId.");
    }
    my $transactionId = $session->db->quickScalar("select transactionId from transactionItem where itemId=?",[$itemId]);
    my $transaction = WebGUI::Shop::Transaction->new($session, $transactionId);
    return $class->new($transaction, $itemId);
}



#-------------------------------------------------------------------

=head2 transaction ( )

Returns a reference to the transaction object.

=cut


#-------------------------------------------------------------------

=head2 write ( )

Stores the object's properties to the database.

=cut

sub write {
    my ($self) = @_;
    my $transaction = $self->transaction;
    my $session     = $transaction->session;
    $self->lastUpdated(WebGUI::DateTime->new($session,time())->toDatabase);
    my %properties       = %{ $self->get() };
    $properties{options} = JSON->new->encode($properties{options});
    delete @properties{qw/transaction item/};
    $session->db->setRow("transactionItem", "itemId", \%properties);
}


1;
