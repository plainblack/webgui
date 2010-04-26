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
use WebGUI::Shop::Tax;
use WebGUI::User;
use Tie::IxHash;

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
private error => my %error;
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
    # cannot use in-shop credit on recurring items
    foreach my $item (@{$self->getItems}) {
        if ($item->getSku->isRecurring) {
            return $self->formatCurrency(0);
        }
    }
    unless (defined $total) {
        $total = $self->calculateTotal
    }
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

=head2 getId ()

Returns the unique id for this cart.

=cut

sub getId {
    my ($self) = @_;
    return $self->get("cartId");
}

#-------------------------------------------------------------------

=head2 getItem ( itemId )

Returns a reference to a WebGUI::Shop::CartItem object.

=head3 itemId

The id of the item to retrieve.

=cut

sub getItem {
    my ($self, $itemId) = @_;
    unless (defined $itemId && $itemId =~ m/^[A-Za-z0-9_-]{22}$/) {
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

    # Check if the shipping address is set and correct
    my $address = eval{$self->getShippingAddress};
    return 0 if WebGUI::Error->caught;

    # Check if the cart has items
    return 0 unless scalar @{ $self->getItems };
    
    # fail if there are multiple recurring items or if
    return 0 if ($self->hasMixedItems);

    # Check minimum cart checkout requirement
    my $total = eval { $self->calculateTotal };
    if (my $e = WebGUI::Error->caught) {
        $error{id $self} = $e->error;
        return 0;
    }
    my $requiredAmount = $self->session->setting->get( 'shopCartCheckoutMinimum' );
    if ( $requiredAmount > 0 ) {
        return 0 if $total < $requiredAmount;
    }

    ##Must have a configured shipping id.
    return 0 if ! $self->get('shipperId');

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
    foreach my $field (qw(billingAddressId shippingAddressId posUserId shipperId creationDate)) {
        $properties{$id}{$field} = (exists $newProperties->{$field}) ? $newProperties->{$field} : $properties{$id}{$field};
    }
    $self->session->db->setRow("cart","cartId",$properties{$id});
}

#-------------------------------------------------------------------

=head2 updateFromForm ( )

Updates the cart totals from form data.

=cut

sub updateFromForm {
    my $self = shift;
    my $form = $self->session->form;
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
    }
    if ($self->hasMixedItems) {
         my $i18n = WebGUI::International->new($self->session, "Shop");
        $error{id $self} = $i18n->get('mixed items warning');
    }
    my $book        = $self->getAddressBook;

    my %billingData = $book->processAddressForm('billing_');
    my $billingAddressId = $form->process('billingAddressId');
    if ($billingAddressId eq 'new_address' && ! exists $billingData{'error'}) {
        my $billingAddress = $book->addAddress(\%billingData);
        $self->update({billingAddressId => $billingAddress->get('addressId'), });
    }
    elsif ($billingAddressId ne 'new_address') {
        $self->update({billinbAddressId => $billingAddressId});
    }

    #$book->processAddressForm()
    my $cartProperties = {};
    $cartProperties->{ shipperId } = $form->process( 'shipperId' ) if $form->process( 'shipperId' );
    $self->update( $cartProperties );
}

#-------------------------------------------------------------------

=head2 www_checkout ( )

Update the cart and then redirect the user to the payment gateway screen.

=cut

sub www_checkout {
    my $self = shift;
    $self->updateFromForm;
    if ($error{id $self} ne "") {
        return $self->www_view;
    }
    $self->session->http->setRedirect($self->session->url->page('shop=pay;method=selectPaymentGateway'));
    return undef;
}

#-------------------------------------------------------------------

=head2 www_continueShopping ( )

Update the cart and the return the user back to the asset.

=cut

sub www_continueShopping {
    my $self = shift;
    $self->updateFromForm;
    if ($error{id $self} ne "") {
        return $self->www_view;
    }
    return undef;
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

=head2 www_removeItem ( )

Remove an item from the cart and then display the cart again.

=cut

sub www_removeItem {
    my $self = shift;
    my $item = $self->getItem($self->session->form->get("itemId"));
    $item->remove;
    return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_setBillingAddress ()

Sets the billing address for the cart.

=cut

sub www_setBillingAddress {
    my $self = shift;
    my $form = $self->session->form;
    $self->update({billingAddressId=>$form->get('billingAddressId')});
    return $self->www_view;
}


#-------------------------------------------------------------------

=head2 www_setShippingAddress ()

Sets the shipping address for the cart or for a cart item if itemId is one of the form params.

=cut

sub www_setShippingAddress {
    my $self = shift;
    my $form = $self->session->form;
    if ($form->get("itemId") ne "") {
        $self->getItem($form->get("itemId"))->update({shippingAddressId=>$form->get('shippingAddressId')}); 
    }
    else {
        $self->update({shippingAddressId=>$form->get('shippingAddressId')});
    }
    return $self->www_view;
}


#-------------------------------------------------------------------

=head2 www_update ( )

Updates the cart totals and then displays the cart again.

=cut

sub www_update {
    my $self = shift;
    $self->updateFromForm;
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
    my @items   = ();
    my $taxDriver = WebGUI::Shop::Tax->getDriver( $session );

    if($url->forceSecureConnection()){
            return "redirect";
    }
    # set up html header
    $session->style->setRawHeadTags(q|
        <script type="text/javascript">
        function setCallbackForAddressChooser (form, itemId) {
            form.shop.value='address';
            form.method.value='view';
            itemId = (itemId == undefined) ? 'null' : "'" + itemId + "'";
            form.callback.value='{"url":"|.$url->page.q|","params":[{"name":"shop","value":"cart"},{"name":"method","value":"setShippingAddress"},{"name":"itemId","value":'+itemId+'}]}';
            form.submit();
        }
        </script>
        |);

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

    # get the shipping address    
    my $address          = eval { $self->getShippingAddress };
    if (my $e = WebGUI::Error->caught("WebGUI::Error::ObjectNotFound")) {
        # choose another address cuz we've got a problem
        $self->update({shippingAddressId=>''});
    }

    # generate template variables for the items in the cart
    my $shippableItemsInCart = 0;
    foreach my $item (@cartItems) {
        my $sku = $item->getSku;
        $sku->applyOptions($item->get("options"));
        my %properties = (
            %{$item->get},
            url                     => $sku->getUrl("shop=cart;method=viewItem;itemId=".$item->getId),
            quantityField           => WebGUI::Form::integer($session, {name=>"quantity-".$item->getId, value=>$item->get("quantity")}),
            isUnique                => ($sku->getMaxAllowedInCart == 1),
            isShippable             => $sku->isShippingRequired,
            extendedPrice           => $self->formatCurrency($sku->getPrice * $item->get("quantity")),
            price                   => $self->formatCurrency($sku->getPrice),
            removeButton            => WebGUI::Form::submit($session, {value=>$i18n->get("remove button"),
               extras=>q|onclick="this.form.method.value='removeItem';this.form.itemId.value='|.$item->getId.q|';this.form.submit;"|}),
            shipToButton    => WebGUI::Form::submit($session, {value=>$i18n->get("Special shipping"), }),
        );
        $shippableItemsInCart ||= $properties{isShippable};
        my $itemAddress = eval {$item->getShippingAddress};
        if ((!WebGUI::Error->caught) && $itemAddress && $address && $itemAddress->getId ne $address->getId) {
            $properties{shippingAddress} = $itemAddress->getHtmlFormatted;
        }
        else {
            $properties{shippingAddress} = '';
        }

        $taxDriver->appendCartItemVars( \%properties, $item );

        push(@items, \%properties);
    }
    my %var = (
        %{$self->get},
        items                   => \@items,
        formHeader              => WebGUI::Form::formHeader($session)
            . WebGUI::Form::hidden($session, {name=>"shop", value=>"cart"})
            . WebGUI::Form::hidden($session, {name=>"method", value=>"update"})
            . WebGUI::Form::hidden($session, {name=>"itemId", value=>""})
            . WebGUI::Form::hidden($session, {name=>"callback", value=>""}),
        formFooter              => WebGUI::Form::formFooter($session),
        updateButton            => WebGUI::Form::submit($session, {value=>$i18n->get("update cart button"), extras=>q|id="updateCartButton"|}),
        continueShoppingButton  => WebGUI::Form::submit($session, {value=>$i18n->get("continue shopping button"), 
            extras=>q|onclick="this.form.method.value='continueShopping';this.form.submit;" id="continueShoppingButton"|}),
#        chooseShippingButton    => WebGUI::Form::submit($session, {value=>$i18n->get("choose shipping button"), 
#            extras=>q|onclick="setCallbackForAddressChooser(this.form);" id="chooseAddressButton"|}),
#        shipToButton    => WebGUI::Form::submit($session, {value=>$i18n->get("ship to button"), 
#            extras=>q|onclick="setCallbackForAddressChooser(this.form);"|}),
        subtotalPrice           => $self->formatCurrency($self->calculateSubtotal()),
        minimumCartAmount       => $session->setting->get( 'shopCartCheckoutMinimum' ) > 0
                                 ? sprintf( '%.2f', $session->setting->get( 'shopCartCheckoutMinimum' ) )
                                 : 0
                                 ,
        shippableItemsInCart    => $shippableItemsInCart,
    );

    # if there is no shipping address we can't check out
#    if (WebGUI::Error->caught) {
#       $var{shippingPrice} = $var{tax} = $self->formatCurrency(0); 
#    }
#
#    # if there is a shipping address calculate tax and shipping options
#    if ($address) {
#        $var{hasShippingAddress} = 1;
#        $var{shippingAddress} = $address->getHtmlFormatted;
#        my $ship = WebGUI::Shop::Ship->new($self->session);
#        my $options = $ship->getOptions($self);
#        my $numberOfOptions = scalar keys %{ $options };
#        if ($numberOfOptions < 1) {
#            $var{shippingOptions} = '';
#            $var{shippingPrice}   = 0;
#            $error{id $self}      = $i18n->get("No shipping plugins configured");
#        }
#        elsif ($numberOfOptions == 1) {
#            my ($option) = keys %{ $options };
#            $self->update({ shipperId => $option });
#            $var{shippingPrice} = $options->{$self->get("shipperId")}->{price};
#            $var{shippingPrice} = $self->formatCurrency($var{shippingPrice});
#        }
#        else {
#            tie my %formOptions, 'Tie::IxHash';
#            $formOptions{''} = $i18n->get('Choose a shipping method');
#            foreach my $option (keys %{$options}) {
#                $formOptions{$option} = $options->{$option}{label}." (".$self->formatCurrency($options->{$option}{price}).")";
#            }
#            $var{shippingOptions} = WebGUI::Form::selectBox($session, {name=>"shipperId", options=>\%formOptions, value=>$self->get("shipperId")});
#            if (!exists $options->{$self->get('shipperId')}) {
#                $self->update({shipperId => ''});
#            }
#            if (my $shipperId = $self->get('shipperId')) {
#                $var{shippingPrice} = $options->{$shipperId}->{price};
#            }
#            else {
#                $var{shippingPrice} = 0;
#                $error{id $self}    = ($i18n->get('Choose a shipping method and update the cart to checkout'));
#            }
#            $var{shippingPrice} = $self->formatCurrency($var{shippingPrice});
#        }
#    }
#  
#    # Tax variables
#    $var{tax} = $self->calculateTaxes;

    #Address form variables
    $var{userIsVisitor} = $session->user->isVisitor;
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
        my $addressBook = $self->getAddressBook;
        my $addresses   = $addressBook->getAddresses;
        tie my %addressOptions, 'Tie::IxHash';
        $addressOptions{'new_address'} = $i18n->get('Add new address');
        foreach my $address (@{ $addresses }) {
            $addressOptions{$address->get('addressId')} = $address->get('label');
        }
        $var{'shippingAddressChooser'} = WebGUI::Form::selectBox($session, {
            name    => 'shipping_addressId',
            options => \%addressOptions,
            value   => $self->get('shippingAddressId') ? $self->get('shippingAddressId') : 'new_address',
        });
        $var{'billingAddressChooser'} = WebGUI::Form::selectBox($session, {
            name    => 'billing_addressId',
            options => \%addressOptions,
            value   => $self->get('billingAddressId') ? $self->get('billingAddressId') : 'new_address',
        });
        my $shippingAddressData = $self->get('shippingAddressId') ? $self->getShippingAddress->get() : {};
        my $billingAddressData  = $self->get('billingAddressId')  ? $self->getBillingAddress->get()  : {};
        $addressBook->appendAddressFormVars(\%var, 'shipping_', $shippingAddressData);
        $addressBook->appendAddressFormVars(\%var, 'billing_',  $billingAddressData);
        $var{sameShippingAsBilling} = WebGUI::Form::yesNo($session, {name => 'sameShippingAsBilling', value => $form->get('sameShippingAsBilling','yesNo')});
    }

    # POS variables
    $var{isCashier} = WebGUI::Shop::Admin->new($session)->isCashier;
    $var{posLookupForm} = WebGUI::Form::email($session, {name=>"posEmail"})
        .WebGUI::Form::submit($session, {value=>$i18n->get('search for email'), 
            extras=>q|onclick="this.form.method.value='lookupPosUser';this.form.submit;"|});
    my $posUser = $self->getPosUser;
    $var{posUsername} = $posUser->username;
    $var{posUserId} = $posUser->userId;

    # calculate price adjusted for in-store credit
    $var{totalPrice} = $var{subtotalPrice}; # + $var{shippingPrice} + $var{tax};
    my $credit = WebGUI::Shop::Credit->new($session, $posUser->userId);
    $var{ inShopCreditAvailable } = $credit->getSum;
    $var{ inShopCreditDeduction } = $credit->calculateDeduction($var{totalPrice});
    $var{ totalPrice            } = $self->formatCurrency($var{totalPrice} + $var{inShopCreditDeduction});
    $var{ readyForCheckout      } = $self->readyForCheckout;
    $var{ error                 } = $error{id $self}; 

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
