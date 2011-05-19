package WebGUI::Shop::Cart;

use strict;

use Class::InsideOut qw{ :std };
use JSON;
use WebGUI::Asset::Template;
use WebGUI::Exception::Shop;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Shop::AddressBook;
use WebGUI::Shop::CartItem;
use WebGUI::Shop::Credit;
use WebGUI::Shop::Ship;
use WebGUI::Shop::Pay;
use WebGUI::Shop::Tax;
use WebGUI::User;
use Tie::IxHash;
use Data::Dumper;

=head1 NAME

Package WebGUI::Shop::Cart

=head1 DESCRIPTION

The cart is the glue that holds a user's order together until they're ready to check out.

=head1 SYNOPSIS

 use WebGUI::Shop::Cart;

 my $cart = WebGUI::Shop::Cart->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;
private properties => my %properties;
public error => my %error;
private addressBookCache => my %addressBookCache;

#-------------------------------------------------------------------

=head2 addItem ( sku )

Adds an item to the cart. Returns a reference to the newly added item.

=head3 sku

A reference to a subclass of WebGUI::Asset::Sku.

=cut

sub addItem {
    my ($self, $sku) = @_;
    unless (defined $sku && $sku->isa("WebGUI::Asset::Sku")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Asset::Sku", got=>(ref $sku), error=>"Need a sku.");
    }
    my $item = WebGUI::Shop::CartItem->create( $self, $sku);
    return $item;
}

#-------------------------------------------------------------------

=head2 calculateShopCreditDeduction ( [ total ] )

Returns the amount of the total that will be deducted by shop credit.

=head3 total

The amount to calculate the deduction against. Defaults to calculateTotal().

=cut

sub calculateShopCreditDeduction {
    my ($self, $total) = @_;
    unless (defined $total) {
        $total = $self->calculateTotal
    }
    # cannot use in-shop credit on recurring items
    return $self->formatCurrency(0) if $self->requiresRecurringPayment;
    return $self->formatCurrency(WebGUI::Shop::Credit->new($self->session, $self->get('posUserId'))->calculateDeduction($total));
}

#-------------------------------------------------------------------

=head2 calculateShipping ()

Returns the cost of shipping for the cart.

=cut

sub calculateShipping {
    my $self = shift;
    
    # get the shipper   
    my $shipper = eval { $self->getShipper  };

    # can't calculate shipping price without a valid shipper
    if (WebGUI::Error->caught) {
       return $self->formatCurrency(0);
    }
    
    # do calculation
    return $self->formatCurrency($shipper->calculate($self));
}

#-------------------------------------------------------------------

=head2 calculateSubtotal ()

Returns the subtotal of the items in the cart.

=cut

sub calculateSubtotal {
    my $self = shift;
    my $subtotal = 0;
    foreach my $item (@{$self->getItems}) {
        my $sku = $item->getSku;
        $subtotal += $sku->getPrice * $item->get("quantity");
    }
    return $subtotal;
}   


#-------------------------------------------------------------------

=head2 calculateTaxes ()

Returns the tax amount on the items in the cart.

=cut

sub calculateTaxes {
    my $self = shift;
    my $tax = WebGUI::Shop::Tax->new($self->session);
    return $self->formatCurrency($tax->calculate($self));
}

#-------------------------------------------------------------------

=head2 calculateTotal ( )

Returns the total price of everything in the cart including tax, shipping, etc.

=cut

sub calculateTotal {
    my ($self) = @_;
    return $self->calculateSubtotal + $self->calculateShipping + $self->calculateTaxes;
}   


#-------------------------------------------------------------------

=head2 create ( session )

Constructor. Creates a new cart object if there’s not one already attached to the current session object. Otherwise just instanciates the existing one.  Returns a reference to the object.

=head3 session

A reference to the current session.

=cut

sub create {
    my ($class, $session) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    my $cartId = $session->id->generate;
    $session->db->write('insert into cart (cartId, sessionId, creationDate) values (?,?,UNIX_TIMESTAMP())', [$cartId, $session->getId]);
    return $class->new($session, $cartId);
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this cart and removes all cartItems contained in it. Also see onCompletePurchase() and empty().

=cut

sub delete {
    my ($self) = @_;
    $self->empty;
    $self->session->db->write("delete from cart where cartId=?",[$self->getId]);
    return undef;
}

#-------------------------------------------------------------------

=head2 empty ()

Removes all items from this cart. Also see onCompletePurchase() and delete().

=cut

sub empty {
    my ($self) = @_;
    foreach my $item (@{$self->getItems}) {
        $item->remove;
    }
}

#-------------------------------------------------------------------

=head2 formatCurrency ( amount )

Formats a number as a float with two digits after the decimal like 0.00.

=head3 amount

The number to format.

=cut

sub formatCurrency {
    my ($self, $amount) = @_;
    unless (defined $amount) {
        WebGUI::Error::InvalidParam->throw(error=>"Need an amount.");
    }
    return sprintf("%.2f", $amount);
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a duplicated hash reference of this object’s data.

=head3 property

Any field − returns the value of a field rather than the hash reference.

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

=head2 getAddressBook ()

Returns a reference to the address book for the user who's cart this is.

=cut

sub getAddressBook {
    my $self = shift;
    my $id = id $self;
    unless (exists $addressBookCache{$id}) {
        $addressBookCache{$id} = WebGUI::Shop::AddressBook->newByUserId($self->session);
    }    
    return $addressBookCache{$id};
}

#-------------------------------------------------------------------

=head2 getBillingAddress ()

Returns the WebGUI::Shop::Address object that is attached to this cart for billing.

=cut

sub getBillingAddress {
    my $self = shift;
    my $book = $self->getAddressBook;
    if (my $addressId = $self->get("billingAddressId")) {
        return $book->getAddress($addressId);
    }
    my $address = $book->getDefaultAddress;
    $self->update({billingAddressId=>$address->getId});
    return $address;
}

#-------------------------------------------------------------------

=head2 getI18nError ()

Returns an internationalized version of the current error, if it exists.

=cut

sub getI18nError {
    my ($self) = @_;
    my $error  = $self->error;
    my $i18n   = WebGUI::International->new($self->session, 'Shop');
    return $error eq 'no billing address'     ? $i18n->get('no billing address')
         : $error eq 'no shipping address'    ? $i18n->get('no shipping address')
         : $error eq 'billing label'          ? $i18n->get('billing label')
         : $error eq 'billing firstName'      ? $i18n->get('billing firstName')
         : $error eq 'billing lastName'       ? $i18n->get('billing lastName')
         : $error eq 'billing address1'       ? $i18n->get('billing address1')
         : $error eq 'billing city'           ? $i18n->get('billing city')
         : $error eq 'billing code'           ? $i18n->get('billing code')
         : $error eq 'billing state'          ? $i18n->get('billing state')
         : $error eq 'billing country'        ? $i18n->get('billing country')
         : $error eq 'billing phoneNumber'    ? $i18n->get('billing phoneNumber')
         : $error eq 'shipping label'         ? $i18n->get('shipping label')
         : $error eq 'shipping firstName'     ? $i18n->get('shipping firstName')
         : $error eq 'shipping lastName'      ? $i18n->get('shipping lastName')
         : $error eq 'shipping address1'      ? $i18n->get('shipping address1')
         : $error eq 'shipping city'          ? $i18n->get('shipping city')
         : $error eq 'shipping code'          ? $i18n->get('shipping code')
         : $error eq 'shipping state'         ? $i18n->get('shipping state')
         : $error eq 'shipping country'       ? $i18n->get('shipping country')
         : $error eq 'shipping phoneNumber'   ? $i18n->get('shipping phoneNumber')
         : $error eq 'no shipping method set' ? $i18n->get('Choose a shipping method and update the cart to checkout')
         : $error eq 'no payment gateway set' ? $i18n->get('Choose a payment gateway and update the cart to checkout')
         : $error ;
}

#-------------------------------------------------------------------

=head2 getId ()

Returns the unique id for this cart.

=cut

sub getId {
    my ($self) = @_;
    return $self->get("cartId");
}

#-------------------------------------------------------------------

=head2 getItem ( itemId )

Returns a reference to a WebGUI::Shop::CartItem object.  Throws an WebGUI::Error::InvalidParam
exception if no itemId is passed, or if an invalid itemId is passed.  It will not catch any
exceptions thrown by actually creating the CartItem, the caller of this method should do that.

=head3 itemId

The id of the item to retrieve.

=cut

sub getItem {
    my ($self, $itemId) = @_;
    unless (defined $itemId && $self->session->id->valid($itemId)) {
        WebGUI::Error::InvalidParam->throw(error=>"Need an itemId.");
    }
    my $item = WebGUI::Shop::CartItem->new($self, $itemId);
    return $item;
}

#-------------------------------------------------------------------

=head2 getItems ( )

Returns an array reference of WebGUI::Asset::Sku objects that are in the cart.

=cut

sub getItems {
    my ($self) = @_;
    my @itemsObjects = ();
    my $items = $self->session->db->read("select itemId from cartItem where cartId=?",[$self->getId]);
    while (my ($itemId) = $items->array) {
        push(@itemsObjects, $self->getItem($itemId));
    }
    return \@itemsObjects;
}

#-------------------------------------------------------------------

=head2 getItemsByAssetId ( assetIds )

Returns an array reference of WebGUI::Asset::Sku objects that have a specific asset id that are in the cart.

=head3 assetIds

An array reference of assetIds to look for.

=cut

sub getItemsByAssetId {
    my ($self, $assetIds) = @_;
    return [] unless (scalar(@{$assetIds}) > 0);
    my @itemsObjects = ();
    my $items = $self->session->db->read("select itemId from cartItem where cartId=? and assetId in (".$self->session->db->quoteAndJoin($assetIds).")",[$self->getId]);
    while (my ($itemId) = $items->array) {
        push(@itemsObjects, $self->getItem($itemId));
    }
    return \@itemsObjects;
}

#-------------------------------------------------------------------

=head2 getPaymentGateway ()

Returns the WebGUI::Shop::PayDriver object that is attached to this cart for payment.

=cut

sub getPaymentGateway {
    my $self = shift;
    return WebGUI::Shop::Pay->new($self->session)->getPaymentGateway($self->get("gatewayId"));
}

#-------------------------------------------------------------------

=head2 getPosUser

Returns the userId of the user making a purchase. If there is a cashier and the cashier has specified a user, then that user will be returned. Otherwise, if it's a direct sale then $session->user will be returned.

=cut

sub getPosUser {
    my $self = shift;
    if ($self->get('posUserId') ne "") {
        return WebGUI::User->new($self->session, $self->get('posUserId'));
    }
    return $self->session->user;    
}

#-------------------------------------------------------------------

=head2 getShipper ()

Returns the WebGUI::Shop::ShipDriver object that is attached to this cart for shipping.

=cut

sub getShipper {
    my $self = shift;
    return WebGUI::Shop::Ship->new($self->session)->getShipper($self->get("shipperId"));
}

#-------------------------------------------------------------------

=head2 getShippingAddress ()

Returns the WebGUI::Shop::Address object that is attached to this cart for shipping.

=cut

sub getShippingAddress {
    my $self = shift;
    my $book = $self->getAddressBook;
    if ($self->get("shippingAddressId")) {
        return $book->getAddress($self->get("shippingAddressId"));
    }
    my $address = $book->getDefaultAddress;
    $self->update({shippingAddressId=>$address->getId});
    return $address;
}

#-------------------------------------------------------------------

=head2 hasMixedItems ()

Returns 1 if there are too many recurring items, or there are mixed recurring and non-recurring items in the cart.

=cut

sub hasMixedItems {
    my $self = shift;
    my $recurring = 0;
    my $nonrecurring = 0;
    foreach my $item (@{$self->getItems}) {
        if ($item->getSku->isRecurring) {
            $recurring += $item->get('quantity');
        }
        else {
            $nonrecurring += $item->get('quantity');
        }
        return 1 if ($recurring > 0 && $nonrecurring > 0);
        return 1 if ($recurring > 1);
    }
    return 0;
}

#-------------------------------------------------------------------

=head2 new ( session, cartId )

Constructor.  Instanciates a cart based upon a cartId.

=head3 session

A reference to the current session.

=head3 cartId

The unique id of a cart to instanciate.

=cut

sub new {
    my ($class, $session, $cartId) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    unless (defined $cartId && $cartId =~ m/^[A-Za-z0-9_-]{22}$/) {
        WebGUI::Error::InvalidParam->throw(error=>"Need a cartId.");
    }
    my $cart = $session->db->quickHashRef('select * from cart where cartId=?', [$cartId]);
    if ($cart->{cartId} eq "") {
        WebGUI::Error::ObjectNotFound->throw(error=>"No such cart.", id=>$cartId);
    }
    my $self = register $class;
    my $id        = id $self;
    $session{ $id }   = $session;
    $properties{ $id } = $cart;
    return $self;
}

#-------------------------------------------------------------------

=head2 newBySession ( session )

Class method that figures out if the user has a cart in their session. If they do it returns it. If they don't it creates it and returns it.

=head3 session

A reference to the current session.

=cut

sub newBySession {
    my ($class, $session) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    my $cartId = $session->db->quickScalar("select cartId from cart where sessionId=?",[$session->getId]);
    return $class->new($session, $cartId) if (defined $cartId and $cartId ne '');
    return $class->create($session);
}

#-------------------------------------------------------------------

=head2 onCompletePurchase ()

Deletes all the items in the cart without calling $item->remove() on them which would affect inventory levels. See also delete() and empty().

=cut

sub onCompletePurchase {
    my $self = shift;
    foreach my $item (@{$self->getItems}) {
        $item->delete;
    }
    $self->delete;
}

#-------------------------------------------------------------------

=head2 readyForCheckout ( )

Returns whether all the required properties of the the cart are set.

=cut

sub readyForCheckout {
    my $self    = shift;
    my $session = $self->session;
    my $book    = $self->getAddressBook;

    # Check if the billing address is set and correct
    my $address = eval{$self->getBillingAddress};
    if (WebGUI::Error->caught) {
        $self->error('no billing address');
        return 0;
    }

    if (my @missingFields = $book->missingFields($address->get)) {
        $self->error('billing '.$missingFields[0]);
        return 0;
    }

    # Check if the shipping address is set and correct
    my $shipAddress = eval{$self->getShippingAddress};
    if (WebGUI::Error->caught) {
        $self->error('no shipping address');
        return 0;
    }

    if (my @missingFields = $book->missingFields($shipAddress->get)) {
        $self->error('shipping '.$missingFields[0]);
        return 0;
    }

    if ($self->requiresShipping) {
        ##Must have a configured shipping id.
        if (! $self->get('shipperId')) {
            $self->error('no shipping method set');
            return 0;
        }

        my $shipper = eval { WebGUI::Shop::ShipDriver->new($session, $self->get('shipperId'))};
        if (my $e = WebGUI::Error->caught) {
            $self->error($e->error);
            return 0;
        }
    }

    # Check if the cart has items
    return 0 unless scalar @{ $self->getItems };
    
    # fail if there are multiple recurring items
    return 0 if ($self->hasMixedItems);

    # Check minimum cart checkout requirement
    my $total = eval { $self->calculateTotal };
    if (my $e = WebGUI::Error->caught) {
        $self->error($e->error);
        return 0;
    }
    my $requiredAmount = $self->session->setting->get( 'shopCartCheckoutMinimum' );
    if ( $requiredAmount > 0 && $total < $requiredAmount) {
        $self->error('required amount not met in cart');
        return 0;
    }

    ##Must have a configured payment method.
    if (! $self->get('gatewayId')) {
        $self->error('no payment gateway set');
        return 0;
    }

    my $gateway = eval { WebGUI::Shop::PayDriver->new($session, $self->get('gatewayId'))};
    if (my $e = WebGUI::Error->caught) {
        $self->error($e->error);
        return 0;
    }

    ##Check for any other logged errors
    return 0 if $error{ id $self };

    # All checks passed so return true
    return 1;
}

#-------------------------------------------------------------------

=head2 requiresRecurringPayment ( )

Returns whether this cart needs to be checked out with a paydriver that can handle recurring payments.

=cut

sub requiresRecurringPayment {
    my $self    = shift;

    # Look for recurring items in the cart
    foreach my $item (@{ $self->getItems }) {
        return 1 if $item->getSku->isRecurring;
    }

    # No recurring items in cart so return false
    return 0;
}

#-------------------------------------------------------------------

=head2 requiresShipping ( )

Returns whether any item in this cart requires shipping.

=cut

sub requiresShipping {
    my $self    = shift;

    # Look for recurring items in the cart
    foreach my $item (@{ $self->getItems }) {
        return 1 if $item->getSku->isShippingRequired;
    }

    # No recurring items in cart so return false
    return 0;
}

#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties in the cart.

=head3 properties

A hash reference that contains one of the following:

=head4 shippingAddressId

The unique id for a shipping address attached to this cart.

=head4 billingAddressId

The unique id for a billing address attached to this cart.

=head4 shipperId

The unique id of the configured shipping driver that will be used to ship these goods.

=head4 posUserId

The ID of a user being checked out, if they're being checked out by a cashier.

=head4 creationDate

The date the cart was created.

=cut

sub update {
    my ($self, $newProperties) = @_;
    unless (defined $newProperties && ref $newProperties eq 'HASH') {
        WebGUI::Error::InvalidParam->throw(error=>"Need a properties hash ref.");
    }
    my $id = id $self;
    foreach my $field (qw(billingAddressId shippingAddressId posUserId gatewayId shipperId creationDate)) {
        $properties{$id}{$field} = (exists $newProperties->{$field}) ? $newProperties->{$field} : $properties{$id}{$field};
    }
    $self->session->db->setRow("cart","cartId",$properties{$id});
}

#-------------------------------------------------------------------

=head2 updateFromForm ( )

Updates the cart totals, the address fields and the shipping and billing options from form data.

=cut

sub updateFromForm {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    foreach my $item (@{$self->getItems}) {
        if ($form->get("quantity-".$item->getId) ne "") {
            eval { $item->setQuantity($form->get("quantity-".$item->getId)) };
            if (WebGUI::Error->caught("WebGUI::Error::Shop::MaxOfItemInCartReached")) {
                my $i18n = WebGUI::International->new($self->session, "Shop");
                $error{id $self} = sprintf($i18n->get("too many of this item"), $item->get("configuredTitle"));
            }
            elsif (my $e = WebGUI::Error->caught) {
                $error{id $self} = "An unknown error has occured: ".$e->message;
            }
        }
        if (my $itemAddressId = $form->get("itemAddress_".$item->getId)) {
            $item->update({shippingAddressId => $itemAddressId});
        }
    }
    if ($self->hasMixedItems) {
         my $i18n = WebGUI::International->new($self->session, "Shop");
        $error{id $self} = $i18n->get('mixed items warning');
    }

    my @cartItemIds = $form->process('remove_item', 'checkList');
    foreach my $cartItemId (@cartItemIds) {
        my $item = eval { $self->getItem($cartItemId); };
        $item->remove if ! Exception::Class->caught();
    }

    ##Visitor cannot have an address book, or set a payment gateway, so skip the rest of this.
    return 1 if $session->user->isVisitor;

    my $book        = $self->getAddressBook;

    my $cartProperties = {};
    my %billingData = $book->processAddressForm('billing_');
    my @missingBillingFields = $book->missingFields(\%billingData);
    my $billingAddressId = $form->process('billingAddressId');
    if ($billingAddressId eq 'new_address' && ! @missingBillingFields) {
        ##Add a new address
        my $newAddress = $book->addAddress(\%billingData);
        $cartProperties->{billingAddressId} = $newAddress->get('addressId');
    }
    elsif ($billingAddressId eq 'update_address' && $self->get('billingAddressId') && ! @missingBillingFields) {
        ##User updated the current address
        my $address = $self->getBillingAddress();
        $address->update(\%billingData);
    }
    elsif ($billingAddressId ne 'new_address' && $billingAddressId ne 'update_address' && $billingAddressId) {
        ##User changed the address selector to another address field
        $cartProperties->{billingAddressId} = $billingAddressId;
    }
    elsif (@missingBillingFields) {
        $self->error('billing '.$missingBillingFields[0]);
    }
    else {
        $self->session->log->warn('billing address: something else: ');
    }
    ##Update now, so that you can add an address AND set the shipping address to be the same at the same time.
    $self->update($cartProperties);

    if ($self->requiresShipping) {
        if ($form->process('sameShippingAsBilling', 'yesNo')) {
            $cartProperties->{shippingAddressId} = $self->get('billingAddressId');
        }
        else {
            my %shippingData = $book->processAddressForm('shipping_');
            my @missingShippingFields = $book->missingFields(\%shippingData);
            my $shippingAddressId = $form->process('shippingAddressId');
            ##No missing shipping fields, if we set to the same as the billing fields
            if (@missingShippingFields) {
                $self->error('shipping '.$missingShippingFields[0]);
            }
            if ($shippingAddressId eq 'new_address' && ! @missingShippingFields) {
                ##Add a new address
                my $newAddress = $book->addAddress(\%shippingData);
                $cartProperties->{shippingAddressId} = $newAddress->get('addressId');
            }
            elsif ($shippingAddressId eq 'update_address' && $self->get('shippingAddressId') && ! @missingShippingFields) {
                ##User changed the address selector
                my $address = $self->getBillingAddress();
                $address->update(\%shippingData);
            }
            elsif ($shippingAddressId ne 'new_address' && $shippingAddressId ne 'update_address' && $shippingAddressId) {
                $cartProperties->{shippingAddressId} = $shippingAddressId;
            }
            else {
                $self->session->log->warn('shipping address: something else: ');
            }
        }
    }

    $cartProperties->{ shipperId } = $form->process( 'shipperId' ) if $form->process( 'shipperId' );
    $cartProperties->{ gatewayId } = $form->process( 'gatewayId' ) if $form->process( 'gatewayId' );
    $self->update( $cartProperties );
}

#-------------------------------------------------------------------

=head2 www_ajaxPrices

Input: shippingId (an addressId)
       billingId  (an addressId)

Output: {
    tax      : 1.25,
    subtotal : 12.00,
    shipping : {
        slfjaldjfalfja: {   
            label    : 'USPS',
            price    : 12.50,
            hasPrice : 1 || 0
        },
        { ... },
        { ... }
    }
}

Takes an addressId and returns JSON shipping options for it, in the form .

=cut

sub www_ajaxPrices {
    my $self     = shift;
    my $session  = $self->session;
    my $form     = $session->form;
    my $billing  = $form->get('billingId');
    my $shipping = $form->get('shippingId');
    my $response = {
        subtotal => $self->calculateSubtotal(),

        tax      => eval {
            my $addr = $shipping || $billing or die;
            $self->update({ shippingAddressId => $addr });
            $self->calculateTaxes();
        } || 0,

        shipping => eval {
            #die unless $shipping;
            if ( $shipping ) {
                $self->update({ shippingAddressId => $shipping });
            }
            my $ship = WebGUI::Shop::Ship->new($self->session);
            $ship->getOptions($self);
        } || [],
    };
    $session->http->setMimeType('text/plain');
    return JSON->new->encode($response);
}

#-------------------------------------------------------------------

=head2 www_ajaxSetCartItemShippingId

Sets the shippingAddressId for a particular cartItem

=cut

sub www_ajaxSetCartItemShippingId {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my $item    = $self->getItem($form->get('itemId'));
    my $address = $form->get('addressId') || undef;
    $item && $item->update({ shippingAddressId => $address });
    $session->http->setMimeType('text/plain');
    return 'ok';
}

#-------------------------------------------------------------------

=head2 www_checkout ( )

All checks and work for checking out are contained in here.

=cut

sub www_checkout {
    my $self    = shift;
    my $session = $self->session;
    ##Setting a shipping address greatly simplifies the Transaction
    if (! $self->requiresShipping && ! $self->get('shippingAddressId')) {
        $self->update({shippingAddressId => $self->get('billingAddressId')});
    }
    if ($self->readyForCheckout()) {
        my $total = $self->calculateTotal;
        ##Handle rounding errors, and checkout immediately if the amount is 0 since
        ##at least the ITransact driver won't accept $0 checkout.
        if (sprintf('%.2f', abs($total + $self->calculateShopCreditDeduction($total))) eq '0.00') {
            my $transaction = WebGUI::Shop::Transaction->create($session, {cart => $self});
            $transaction->completePurchase('zero', 'success', 'success');
            $self->onCompletePurchase;
            $transaction->sendNotifications();
            return $transaction->thankYou();
        }
        my $gateway = $self->getPaymentGateway;
        return $gateway->www_getCredentials;
    }
    return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_lookupPosUser ( )

Adds a Point of Sale user to the cart.

=cut

sub www_lookupPosUser {
    my $self = shift;
    my $session = $self->session;
    my $email = $session->form->get('posEmail','email');
    my $user = WebGUI::User->newByEmail($session, $email);
    unless (defined $user) {
        $user = WebGUI::User->newByUsername($session, $email);
        unless (defined $user) {
            $user = WebGUI::User->new($session, "new");
            $user->username($email);
            $user->profileField('email', $email);
        }
    }
    $self->update({posUserId=>$user->userId});
    return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_update ( )

Updates the cart totals, addresses, shipping driver and payment gateway. If requested, and the
cart is ready, calls the www_getCredentials method from the selected payment gateway.

If the cart total, after taxes, shipping, coupons and shop credit is zero, does the checkout
immediately without calling a payment gateway.

Otherwise, returns the user back to the cart.

=cut

sub www_update {
    my $self    = shift;
    my $session = $self->session;
    $self->updateFromForm;
    if ($session->form->get('continue_shopping')) {
        return undef;
    }
    elsif ($session->form->get('checkout')) {
        ##Shortcut method for checkout, so that the cart form contents don't get lost.
        return $self->www_checkout();
    }
    return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_view ( )

Displays the shopping cart.

=cut

sub www_view {
    my $self    = shift;
    my $session = $self->session;
    my $url     = $session->url;
    my $form    = $session->form;
    my $i18n    = WebGUI::International->new($session, "Shop");
    my $taxDriver = WebGUI::Shop::Tax->getDriver( $session );

    if($url->forceSecureConnection()){
            return "redirect";
    }

    my @cartItems = @{$self->getItems};
    if(scalar(@cartItems) < 1) {
        # there are no items in the cart, return a message to the template
        my %var = (
            message => $i18n->get('empty cart')
        );

        # render the cart
        my $template = WebGUI::Asset::Template->new($session, $session->setting->get("shopCartTemplateId"));
        return $session->style->userStyle($template->process(\%var));
    }

    my %var = (
        %{$self->get},
        formHeader              => WebGUI::Form::formHeader($session, { extras => q|id="wgCartId"|, })
                                .  WebGUI::Form::hidden($session, {name=>"shop",   value=>"cart"})
                                .  WebGUI::Form::hidden($session, {name=>"method", value=>"update"})
                                .  WebGUI::Form::hidden($session, {name=>"itemId", value=>""})
                                ,
        formFooter              => WebGUI::Form::formFooter($session),
        updateButton            => WebGUI::Form::submit($session, {value=>$i18n->get("update cart button"), id=>"updateCartButton"}),
        checkoutButton          => WebGUI::Form::submit($session, {name => 'checkout', value=>$i18n->get("checkout button"), id=>"checkoutButton"}),
        continueShoppingButton  => WebGUI::Form::submit($session, {
                                        name   => 'continue_shopping',
                                        value  => $i18n->get("continue shopping button"), 
                                        id     => 'continueShoppingButton',
                                   }),
        minimumCartAmount       => $session->setting->get( 'shopCartCheckoutMinimum' ) > 0
                                 ? sprintf( '%.2f', $session->setting->get( 'shopCartCheckoutMinimum' ) )
                                 : 0
                                 ,
        userIsVisitor           => $session->user->isVisitor,
        shippableItemsInCart    => $self->requiresShipping,
    );


    # get the shipping address    
    my $address = eval { $self->getShippingAddress };
    if (my $e = WebGUI::Error->caught("WebGUI::Error::ObjectNotFound") && $self->get('shippingAddressId')) {
        # choose another address cuz we've got a problem
        $self->update({shippingAddressId=>''});
    }

    # generate template variables for the items in the cart
    my @items   = ();
    tie my %addressOptions,        'Tie::IxHash';
    if (! $var{userIsVisitor}) {
        my $addressBook = $self->getAddressBook;
        my $addresses   = $addressBook->getAddresses;
        foreach my $address (@{ $addresses }) {
            $addressOptions{$address->get('addressId')} = $address->get('label');
        }
    }

    tie my %specialAddressOptions, 'Tie::IxHash';
    $specialAddressOptions{''} = $i18n->get("Special shipping");
    %specialAddressOptions = (%specialAddressOptions, %addressOptions);

    foreach my $item (@cartItems) {
        my $sku = $item->getSku;
        $sku->applyOptions($item->get("options"));
        my %properties = (
            %{$item->get},
            url             => $sku->getUrl("shop=cart;method=viewItem;itemId=".$item->getId),
            quantityField   => WebGUI::Form::integer($session, {name=>"quantity-".$item->getId, value=>$item->get("quantity"), size=>5,}),
            isUnique        => ($sku->getMaxAllowedInCart == 1),
            isShippable     => $sku->isShippingRequired,
            extendedPrice   => $self->formatCurrency($sku->getPrice * $item->get("quantity")),
            price           => $self->formatCurrency($sku->getPrice),
            removeBox       => WebGUI::Form::checkbox($session, {name => 'remove_item', value => $item->get('itemId')}),
        );
        my $itemAddress = eval {$item->getShippingAddress};
        my $itemAddressId;
        if ((!WebGUI::Error->caught) && $itemAddress && $address && $itemAddress->getId ne $address->getId) {
            $properties{shippingAddress} = $itemAddress->getHtmlFormatted;
            $itemAddressId               = $itemAddress->getId;
        }
        else {
            $properties{shippingAddress} = '';
            $itemAddressId               = '';
        }
        if (! $var{userIsVisitor} && @cartItems > 1) {
            $properties{itemAddressChooser} = WebGUI::Form::selectBox($session, {
                                                  name    => "itemAddress_".$item->getId,
                                                  value   => $itemAddressId,
                                                  options => \%specialAddressOptions,
                                                  extras  => q|class="itemAddressMenu"|,
                                              });
            $taxDriver->appendCartItemVars( \%properties, $item );
        }


        push(@items, \%properties);
    }

    $var{items}                = \@items;
    if (! $var{userIsVisitor} && $var{shippableItemsInCart}) {
        my $ship = WebGUI::Shop::Ship->new($self->session);
        my $options = $ship->getOptions($self);
        my $numberOfOptions = scalar keys %{ $options };
        if (! $numberOfOptions) {
            $var{shippingOptions} = '';
            $var{shippingPrice}   = 0;
            $self->error($i18n->get("No shipping plugins configured"));
        }
        else {
            tie my %formOptions, 'Tie::IxHash';
            $formOptions{''} = $i18n->get('Choose a shipping method');
            foreach my $optionId (keys %{$options}) {
                $formOptions{$optionId} = $options->{$optionId}{label};
                if ($options->{$optionId}->{hasPrice}) {
                    $formOptions{$optionId} .= ' ('.$self->formatCurrency($options->{$optionId}{price}).')';
                }
            }
            my $shipperId = $self->get('shipperId');
            if (!$shipperId && $numberOfOptions == 1) {
                my ($option) = keys %{ $options };
                $self->update({shipperId => $option});
                $shipperId = $option;
            }
            $var{shippingOptions} = WebGUI::Form::selectBox($session, {name=>"shipperId", options=>\%formOptions, value=>$shipperId || ''});
            if (!exists $options->{$shipperId}) {
                $self->update({shipperId => ''});
                $shipperId = '';
            }
            if ($shipperId) {
                $var{shippingPrice} = $options->{$shipperId}->{price};
            }
            else {
                $var{shippingPrice} = 0;
                $self->error($i18n->get('Choose a shipping method and update the cart to checkout'));
            }
            $var{shippingPrice} = $shipperId && $options->{$shipperId}->{hasPrice} ? $self->formatCurrency($var{shippingPrice}) : '';
            $var{tax} = $self->calculateTaxes;
        }
    }
    else {
       $var{shippingPrice} = $var{tax} = $self->formatCurrency(0); 
    }


    # Tax variables

    #Address form variables
    if ($var{userIsVisitor}) {
        $var{loginFormHeader} = WebGUI::Form::formHeader($session, {action => $session->url->page})
                              . WebGUI::Form::hidden($session,{ name => 'op',     value => 'auth'})
                              . WebGUI::Form::hidden($session,{ name => 'method', value => 'login'})
                              ;
        $var{loginFormUsername} = WebGUI::Form::text($session, { name => 'username', size => 12, });
        $var{loginFormPassword} = WebGUI::Form::password($session, { name => 'identifier', size => 12, });
        $var{loginFormButton}   = WebGUI::Form::submit($session, { value => $i18n->get(52,'WebGUI'), });
        $var{registerLink}      = $session->url->page('op=auth;method=createAccount');
        $session->scratch->set('redirectAfterLogin', $session->url->page('shop=cart'));
        $var{loginFormFooter}   = WebGUI::Form::formFooter($session)
    }
    else {
        ##Address form variables
        tie my %billingAddressOptions, 'Tie::IxHash';
        $billingAddressOptions{'new_address'} = $i18n->get('Add new address');

        my $billingAddressId = $self->get('billingAddressId');
        if ($billingAddressId) {
            my $billingAddress = eval { $self->getBillingAddress };
            if ( defined $billingAddress ) {
                $billingAddressOptions{'update_address'} = sprintf $i18n->get('Update %s'), $billingAddress->get('label');
            }
            elsif (my $e = WebGUI::Error->caught("WebGUI::Error::ObjectNotFound") && $self->get('billingAddressId')) {
                $self->update({billingAddressId=>''});
            }
        }

        %billingAddressOptions = (%billingAddressOptions, %addressOptions);

        $var{'billingAddressChooser'} = WebGUI::Form::selectBox($session, {
            name    => 'billingAddressId',
            options => \%billingAddressOptions,
            value   => $billingAddressId ? $billingAddressId : 'new_address',
        });

        tie my %shippingAddressOptions, 'Tie::IxHash';
        $shippingAddressOptions{'new_address'} = $i18n->get('Add new address');

        my $shippingAddressId = $self->get('shippingAddressId');
        if ($shippingAddressId) {
            my $shippingAddress = eval { $self->getShippingAddress };
            if ( defined $shippingAddress ) {
               $shippingAddressOptions{'update_address'} = sprintf $i18n->get('Update %s'), $shippingAddress->get('label');
            }
        }
        %shippingAddressOptions = (%shippingAddressOptions, %addressOptions);

        $var{'shippingAddressChooser'} = WebGUI::Form::selectBox($session, {
            name    => 'shippingAddressId',
            options => \%shippingAddressOptions,
            value   => $shippingAddressId ? $shippingAddressId : 'new_address',
        });

        my $shippingAddressData = $self->get('shippingAddressId') ? $self->getShippingAddress->get() : {};
        my $billingAddressData  = $self->get('billingAddressId')  ? $self->getBillingAddress->get()  : {};
        my $addressBook = $self->getAddressBook;
        $addressBook->appendAddressFormVars(\%var, 'shipping_', $shippingAddressData);
        $addressBook->appendAddressFormVars(\%var, 'billing_',  $billingAddressData);

        $var{sameShippingAsBilling} = WebGUI::Form::yesNo($session, {
            name => 'sameShippingAsBilling',
            value => $self->get('billingAddressId') && $self->get('billingAddressId') eq $self->get('shippingAddressId'),
        });
    }

    # Payment methods
    my $pay = WebGUI::Shop::Pay->new($session);
    tie my %paymentOptions, 'Tie::IxHash';
    $paymentOptions{''} = $i18n->get('Choose a payment method');
    my $gateways = $pay->getOptions($self);
    while (my ($gatewayId, $label) = each %{ $gateways }) {
        $paymentOptions{$gatewayId} = $label;
    }
    $var{paymentOptions} = WebGUI::Form::selectBox($session, {
        name    => 'gatewayId',
        options => \%paymentOptions,
        value   => $self->get('gatewayId') || $form->get('gatewayId') || '',
    });

    # POS variables
    $var{isCashier}     = WebGUI::Shop::Admin->new($session)->isCashier;
    $var{posLookupForm} = WebGUI::Form::email($session, {name=>"posEmail"})
        .WebGUI::Form::submit($session, {value=>$i18n->get('search for email'), 
            extras=>q|onclick="this.form.method.value='lookupPosUser';this.form.submit;"|});
    my $posUser       = $self->getPosUser;
    $var{posUsername} = $posUser->username;
    $var{posUserId}   = $posUser->userId;

    # calculate price adjusted for in-store credit
    $var{subtotalPrice}           = $self->formatCurrency($self->calculateSubtotal());
    $var{totalPrice}              = $var{subtotalPrice} + $var{shippingPrice} + $var{tax};
    my $credit = WebGUI::Shop::Credit->new($session, $posUser->userId);
    $var{ inShopCreditAvailable } = $credit->getSum;
    $var{ inShopCreditDeduction } = $self->calculateShopCreditDeduction($var{totalPrice});
    $var{ totalPrice            } = $self->formatCurrency($var{totalPrice} + $var{inShopCreditDeduction});
    foreach my $field (qw/subtotalPrice inShopCreditAvailable inShopCreditDeduction totalPrice shippingPrice tax/) {
        $var{$field} = sprintf q|<span id="%sWrap">%s</span>|, $field, $var{$field};
    }
    $var{ error } = $self->getI18nError; 

    # render the cart
    my $template = WebGUI::Asset::Template->new($session, $session->setting->get("shopCartTemplateId"));
    return $session->style->userStyle($template->process(\%var));
}

#-------------------------------------------------------------------

=head2 www_viewItem ( )

Displays the configured item.

=cut

sub www_viewItem {
    my $self = shift;
    my $itemId = $self->session->form->get("itemId");
    my $item = eval { $self->getItem($itemId) };
    if (WebGUI::Error->caught()) {
        return $self->www_view;
    }
    return $item->getSku->www_view;
}


1;
