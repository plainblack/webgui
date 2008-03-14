package WebGUI::Shop::Transaction;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Asset::Template;
use WebGUI::Exception::Shop;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Shop::AddressBook;
use WebGUI::Shop::TransactionItem;

=head1 NAME

Package WebGUI::Shop::Transaction

=head1 DESCRIPTION

This package keeps records of every puchase made.

=head1 SYNOPSIS

 use WebGUI::Shop::Transaction;

 my $transaction = WebGUI::Shop::Transaction->new($session, $id);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;
private properties => my %properties;

#-------------------------------------------------------------------

=head2 addItem ( cartitem )

Adds an item to the transaction. Returns a reference to the newly added item.

=head3 cartitem

A reference to a subclass of WebGUI::Shop::CartItem.

=cut

sub addItem {
    my ($self, $cartItem) = @_;
    my $item = WebGUI::Shop::TransactionItem->create( $self, $cartItem);
    return $item;
}

#-------------------------------------------------------------------

=head2 create ( session, properties )

Constructor. Creates a new transaction object. Returns a reference to the object.

=head3 session

A reference to the current session.

=head3 properties

See update().

=cut

sub create {
    my ($class, $session, $properties) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    my $transactionId = $session->id->generate;
    $session->db->write('insert into transaction (transactionId, userId, username, dateOfPurchase) values (?,?,?,now())',
        [$transactionId, $session->user->userId, $session->user->username]);
    my $self = $class->new($session, $transactionId);
    $self->update($properties);
    return $self;
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this transaction and all transactionItems contained in it.

=cut

sub delete {
    my ($self) = @_;
    foreach my $item (@{$self->getItems}) {
        $item->delete;
    } 
    $self->session->db->write("delete from transaction where transactionId=?",[$self->getId]);
    undef $self;
    return undef;
}

#-------------------------------------------------------------------

=head2 formatCurrency ( amount )

Formats a number as a float with two digits after the decimal like 0.00.

=head3 amount

The number to format.

=cut

sub formatCurrency {
    my ($self, $amount) = @_;
    return sprintf("%.2f", $amount);
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a duplicated hash reference of this objectÕs data.

=head3 property

Any field ? returns the value of a field rather than the hash reference.

=cut

sub get {
    my ($self, $name) = @_;
    if (defined $name) {
        return $properties{id $self}{$name};
    }
    my %copyOfHashRef = %{$properties{id $self}};
    return \%copyOfHashRef;
}

#-------------------------------------------------------------------

=head2 getId ()

Returns the unique id for this transaction.

=cut

sub getId {
    my ($self) = @_;
    return $self->get("transactionId");
}

#-------------------------------------------------------------------

=head2 getItem ( itemId )

Returns a reference to a WebGUI::Shop::TransactionItem object.

=head3 itemId

The id of the item to retrieve.

=cut

sub getItem {
    my ($self, $itemId) = @_;
    return WebGUI::Shop::TransactionItem->new($self, $itemId);
}

#-------------------------------------------------------------------

=head2 getItems ( )

Returns an array reference of WebGUI::Shop::TransactionItem objects that are in the transaction.

=cut

sub getItems {
    my ($self) = @_;
    my @itemsObjects = ();
    my $items = $self->session->db->read("select itemId from transactionItem where transactionId=?",[$self->getId]);
    while (my ($itemId) = $items->array) {
        push(@itemsObjects, $self->getItem($itemId));
    }
    return \@itemsObjects;
}

#-------------------------------------------------------------------

=head2 new ( session, transactionId )

Constructor.  Instanciates a transaction based upon a transactionId.

=head3 session

A reference to the current session.

=head3 transactionId

The unique id of a transaction to instanciate.

=cut

sub new {
    my ($class, $session, $transactionId) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    unless (defined $transactionId) {
        WebGUI::Error::InvalidParam->throw(error=>"Need a transactionId.");
    }
    my $transaction = $session->db->quickHashRef('select * from transaction where transactionId=?', [$transactionId]);
    if ($transaction->{transactionId} eq "") {
        WebGUI::Error::ObjectNotFound->throw(error=>"No such transaction.", id=>$transactionId);
    }
    my $self = register $class;
    my $id        = id $self;
    $session{ $id }   = $session;
    $properties{ $id } = $transaction;
    return $self;
}

#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties in the transaction.

=head3 properties

A hash reference that contains one of the following:

=head4 cart

A reference to a cart object. Will pull shipping method, shipping address, tax, items, total, and coupon from
it. Alternatively you can set manually any of the following properties that are set by cart automatically:
amount shippingAddressId shippingAddressName shippingAddress1 shippingAddress2 shippingAddress3 shippingCity
shippingState shippingCountry shippingCode shippingPhoneNumber shippingDriverId shippingDriverLabel shippingPrice
couponId couponTitle couponDiscount taxes

You can also use the addItem() method to manually add items to the transaction rather than passing a cart full of items.

=head4 paymentAddress

A reference to a WebGUI::Shop::Address that contains the payment address. Alternatively you can set manually
any of the properties that are set by payment address automatically: paymentAddressId paymentAddressName
paymentAddress1 paymentAddress2 paymentAddress3 paymentCity paymentState paymentCountry paymentCode
paymentPhoneNumber 

=head4 paymentMethod

A reference to a WebGUI::Shop::PayDriver subclass that is used to make payment. Alternatively you can set
manually any of the properties that are set by payment method automatically: paymentDriverId paymentDriverLabel

=head4 isSuccessful

A boolean indicating whether the transaction was completed successfully.

=head4 transactionCode

The transaction id or code given by the payment gateway.

=head4 statusCode

The status code that came back from the payment gateway when trying to process the payment.

=head4 statusMessage

The extended status message that came back from the payment gateway when trying to process the payment.

=cut

sub update {
    my ($self, $newProperties) = @_;
    my $id = id $self;
    if (exists $newProperties->{cart}) {
        my $cart = $newProperties->{cart};
        $newProperties->{taxes} = $cart->getTaxes;
        my $address = $cart->getShippingAddress;
        $newProperties->{shippingAddressId} = $address->getId;
        $newProperties->{shippingAddressName} = $address->get('name');
        $newProperties->{shippingAddress1} = $address->get('address1');
        $newProperties->{shippingAddress2} = $address->get('address2');
        $newProperties->{shippingAddress3} = $address->get('address3');
        $newProperties->{shippingCity} = $address->get('city');
        $newProperties->{shippingState} = $address->get('state');
        $newProperties->{shippingCountry} = $address->get('country');
        $newProperties->{shippingCode} = $address->get('code');
        $newProperties->{shippingPhoneNumber} = $address->get('phoneNumber');
        my $shipper = $cart->getShipper;
        $newProperties->{shippingDriverId} = $shipper->getId;
        $newProperties->{shippingDriverLabel} = $shipper->get('label');
        $newProperties->{shippingPrice} = $shipper->calculate($cart);
        $newProperties->{couponId} = $cart->get('couponId');
        $newProperties->{couponTitle} = '';
        $newProperties->{couponDiscount} = '';
        $newProperties->{amount} = $cart->getSubtotal + $newProperties->{couponDiscount} + $newProperties->{shippingPrice} + $newProperties->{taxes};
        foreach my $item (@{$cart->getItems}) {
            $self->addItem({item=>$item});
        }
    }
    if (exists $newProperties->{paymentAddress}) {
        my $address = $newProperties->{paymentAddress};
        $newProperties->{paymentAddressId} = $address->getId;
        $newProperties->{paymentAddressName} = $address->get('name');
        $newProperties->{paymentAddress1} = $address->get('address1');
        $newProperties->{paymentAddress2} = $address->get('address2');
        $newProperties->{paymentAddress3} = $address->get('address3');
        $newProperties->{paymentCity} = $address->get('city');
        $newProperties->{paymentState} = $address->get('state');
        $newProperties->{paymentCountry} = $address->get('country');
        $newProperties->{paymentCode} = $address->get('code');
        $newProperties->{paymentPhoneNumber} = $address->get('phoneNumber');
    }
    if (exists $newProperties->{paymentMethod}) {
        my $pay = $newProperties->{paymentMethod};
        $newProperties->{paymentDriverId} = $pay->getId;
        $newProperties->{paymentDriverLabel} = $pay->get('label');
    }
    my @fields = (qw( isSuccessful transactionCode statusCode statusMessage amount shippingAddressId
        shippingAddressName shippingAddress1 shippingAddress2 shippingAddress3 shippingCity shippingState
        shippingCountry shippingCode shippingPhoneNumber shippingDriverId shippingDriverLabel
        shippingPrice paymentAddressId paymentAddressName
        paymentAddress1 paymentAddress2 paymentAddress3 paymentCity paymentState paymentCountry paymentCode
        paymentPhoneNumber paymentDriverId paymentDriverLabel couponId couponTitle couponDiscount taxes ));
    foreach my $field (@fields) {
        $properties{$id}{$field} = (exists $newProperties->{$field}) ? $newProperties->{$field} : $properties{$id}{$field};
    }
    $self->session->db->setRow("transaction","transactionId",$properties{$id});
}




1;
