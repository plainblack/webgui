package WebGUI::Shop::Transaction;

use strict;

use Class::InsideOut qw{ :std };
use JSON qw{ from_json };
use WebGUI::Asset::Template;
use WebGUI::Exception::Shop;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Inbox;
use WebGUI::Paginator;
use WebGUI::Shop::Admin;
use WebGUI::Shop::AddressBook;
use WebGUI::Shop::Credit;
use WebGUI::Shop::TransactionItem;
use WebGUI::Shop::Pay;
use WebGUI::User;

=head1 NAME

Package WebGUI::Shop::Transaction

=head1 DESCRIPTION

This package keeps records of every puchase made.

=head1 SYNOPSIS

 use WebGUI::Shop::Transaction;

 my $transaction = WebGUI::Shop::Transaction->new($session, $id);
 
 # typical transaction goes like this:
 my $transaction = WebGUI::Shop::Transaction->create({ cart=>$cart });
 my ($transactionNumber, $status, $message) = $paymentMethod->tryTransaction;
 if ($status eq "somekindofsuccess") {
    $transaction->completePurchase($cart, $transactionNumber, $status, $message);
 }
 else {
    $transaction->denyPurchase($transactionNumber, $status, $message);
 }


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

=head2 cancelRecurring ( )

Cancel a recurring transaction, and calls onCancelRecurring in whatever sku is attached to this transaction. If the
cancelation fails, returns an error message.

=cut

sub cancelRecurring {
    my ($self) = @_;
    my ($success, $message) = $self->getPaymentGateway->cancelRecurringPayment($self);

    # Handle failed cancelation.
    unless ($success) {
        return 
            "Canceling recurring transaction failed. The following response was received from the payment gateway:<br/>"
            . $message;
    }

    my ($item) = @{ $self->getItems };
    $item->getSku->onCancelRecurring($item);
    my $recurringId = ($self->get('originatingTransactionId') || $self->getId);
    $self->session->db->write("update transaction set isRecurring=0 where transactionId=? or originatingTransactionId=?",[$recurringId,$recurringId]);

    return undef;
}

#-------------------------------------------------------------------

=head2 completePurchase ( transactionCode, statusCode, statusMessage )

See also denyPurchase(). Completes a purchase by updating the transaction as a success, and calling onCompletePurchase on all the skus in the transaction.

=head3 transactionCode

The transaction id or code given by the payment gateway.

=head3 statusCode

The status code that came back from the payment gateway when trying to process the payment.

=head3 statusMessage

The extended status message that came back from the payment gateway when trying to process the payment.

=cut

sub completePurchase {
    my ($self, $transactionCode, $statusCode, $statusMessage) = @_;
    if ($self->get('shopCreditDeduction') < 0) {
        WebGUI::Shop::Credit->new($self->session)->adjust($self->get('shopCreditDeduction'), "Paid for transaction ".$self->getId);        
    }
    foreach my $item (@{$self->getItems}) {
        $item->getSku->onCompletePurchase($item);
    }
    $self->update({
        transactionCode => $transactionCode,
        isSuccessful    => 1,
        statusCode      => $statusCode,
        statusMessage   => $statusMessage,
        });
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
    my $cashier = $session->user;
    my $posUser = $cashier;
    my $cart = $properties->{cart};
    if (defined $cart) {
        $posUser = $cart->getPosUser;
    }
    $session->db->write('insert into transaction (transactionId, userId, username, cashierUserId, dateOfPurchase) values (?,?,?,?,now())',
        [$transactionId, $posUser->userId, $posUser->username, $cashier->userId]);
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

=head2 denyPurchase ( transactionCode, statusCode, statusMessage )

Completes a purchase as a failure. It could be that the user didn't enter their credit cart correctly, or they may have insufficient funds.

=head3 transactionCode

The transaction id or code given by the payment gateway.

=head3 statusCode

The status code that came back from the payment gateway when trying to process the payment.

=head3 statusMessage

The extended status message that came back from the payment gateway when trying to process the payment.

=cut

sub denyPurchase {
    my ($self, $transactionCode, $statusCode, $statusMessage) = @_;
    $self->update({
        isSuccessful    => 0,
        transactionCode => $transactionCode,
        statusCode      => $statusCode,
        statusMessage   => $statusMessage
        });
}

#-------------------------------------------------------------------

=head2 duplicate ( [ overrideProperties ] )

Creates a new transaction with identical properties to the to this transaction .

=head3 overrideProperties

An optional hash ref containing transaction properties you want to override.

=cut

sub duplicate {
    my $self                = shift;
    my $overrideProperties  = shift || {};
    my $session             = $self->session;

    # Fetch the properties for the duplicate transaction and apply the overrides
    my $transactionProperties = { %{ $self->get }, %{ $overrideProperties } };
    
    # Create a new transactions with the duplicated properties
    my $newTransaction = WebGUI::Shop::Transaction->create( $session, $transactionProperties );

    # Copy the items in the subscription
    foreach my $item ( @{ $self->getItems } ) {
        $newTransaction->addItem( $item->get );
    }

    return $newTransaction;
}

#-------------------------------------------------------------------

=head2 formatAddress ( address )

Returns a formatted address.

=head3 address

A hash reference with the address properties.

=cut

sub formatAddress {
    my ($self, $address) = @_;
    my $formatted = $address->{name} . "<br />" . $address->{address1} . "<br />";
    $formatted .= $address->{address2} . "<br />" if ($address->{address2} ne "");
    $formatted .= $address->{address3} . "<br />" if ($address->{address3} ne "");
    $formatted .= $address->{city} . ", ";
    $formatted .= $address->{state} . " " if ($address->{state} ne "");
    $formatted .= $address->{code} if ($address->{code} ne "");
    $formatted .= '<br />' . $address->{country};
    $formatted .= '<br />' . $address->{phoneNumber};
    return $formatted;
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

Returns a duplicated hash reference of this object's data.

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

=head2 getPaymentGateway ()

Returns a reference to the payment gateway attached to this transaction.

=cut

sub getPaymentGateway {
    my ($self) = @_;
    my $pay = WebGUI::Shop::Pay->new($self->session);
    return $pay->getPaymentGateway($self->get('paymentDriverId'));
}


#-------------------------------------------------------------------

=head2 getTransactionIdsForUser (session, [ userId ])

Returns an array reference of transactionIds for a given user ordered by date descending. Class method.

=head3 userId

The id of the user to fetch transactions for. Defaults to the current user.

=cut

sub getTransactionIdsForUser {
    my ($class, $session, $userId) = @_;
    unless (defined $userId) {
        $userId = $session->user->userId;
    }
    return $session->db->buildArrayRef("select transactionId from transaction where userId=? order by dateOfPurchase desc",[$userId]);
}

#-------------------------------------------------------------------

=head2 getTransactionVars 

Returns a set of template variables for the current transaction.

=cut

sub getTransactionVars {
    my $self = shift;
    my $url  = $self->session->url;
    my $i18n = WebGUI::International->new( $self->session, 'Shop' );

    my $var = {
        %{ $self->get },
        viewDetailUrl           => $url->page( 'shop=transaction;method=viewMy;transactionId='.$self->getId, 1 ),
        cancelRecurringUrl      => $url->page('shop=transaction;method=cancelRecurring;transactionId='.$self->getId),
        amount                  => sprintf( "%.2f", $self->get('amount') ),
        inShopCreditDeduction   => sprintf( "%.2f", $self->get('shopCreditDeduction') ),
        taxes                   => sprintf( "%.2f", $self->get('taxes') ),
        shippingPrice           => sprintf( "%.2f", $self->get('shippingPrice') ),
        shippingAddress         => $self->formatAddress( {
            name        => $self->get('shippingAddressName'),
            address1    => $self->get('shippingAddress1'),
            address2    => $self->get('shippingAddress2'),
            address3    => $self->get('shippingAddress3'),
            city        => $self->get('shippingCity'),
            state       => $self->get('shippingState'),
            code        => $self->get('shippingCode'),
            country     => $self->get('shippingCountry'),
            phoneNumber => $self->get('shippingPhoneNumber'),
        } ),
        paymentAddress          =>  $self->formatAddress({
            name        => $self->get('paymentAddressName'),
            address1    => $self->get('paymentAddress1'),
            address2    => $self->get('paymentAddress2'),
            address3    => $self->get('paymentAddress3'),
            city        => $self->get('paymentCity'),
            state       => $self->get('paymentState'),
            code        => $self->get('paymentCode'),
            country     => $self->get('paymentCountry'),
            phoneNumber => $self->get('paymentPhoneNumber'),
        } ),
    };
    
    # items
    my @items = ();
    foreach my $item (@{$self->getItems}) {
        my $address = '';
        if ($self->get('shippingAddressId') ne $item->get('shippingAddressId')) {
            $address = $self->formatAddress({
                            name        => $item->get('shippingAddressName'),
                            address1    => $item->get('shippingAddress1'),
                            address2    => $item->get('shippingAddress2'),
                            address3    => $item->get('shippingAddress3'),
                            city        => $item->get('shippingCity'),
                            state       => $item->get('shippingState'),
                            code        => $item->get('shippingCode'),
                            country     => $item->get('shippingCountry'),
                            phoneNumber => $item->get('shippingPhoneNumber'),
                            });
        }
 
        # Post purchase actions
        my $actionsLoop = [];
        my $actions     = $item->getSku->getPostPurchaseActions( $item );
        for my $label ( keys %{$actions} ) {
            push @{$actionsLoop}, {
                label       => $label,
                url         => $actions->{$label},
            }
        }

        my %taxConfiguration = %{ from_json( $item->get( 'taxConfiguration' ) || '{}' ) };
        my %taxVars          =  
            map     { ( "tax_$_" => $taxConfiguration{ $_ } ) }
            keys    %taxConfiguration;

        my $price       = $item->get('price');
        my $quantity    = $item->get('quantity');
        my $taxRate     = $item->get('taxRate');
        my $taxAmount   = $price * $taxRate / 100;

        push @items, {
            %{$item->get},
            %taxVars,
            viewItemUrl             => $url->page('shop=transaction;method=viewItem;transactionId='.$self->getId.';itemId='.$item->getId, 1),
            price                   => sprintf("%.2f", $item->get('price')),
            pricePlusTax            => sprintf( "%.2f", $price + $taxAmount ),
            extendedPrice           => sprintf( "%.2f", $quantity * $price ),
            extendedPricePlusTax    => sprintf( "%.2f", $quantity * ( $price + $taxAmount ) ),
            itemShippingAddress     => $address,
            orderStatus             => $i18n->get( $item->get('orderStatus'), 'Shop' ),
            actionsLoop             => $actionsLoop,
        };
    }
    $var->{items} = \@items;

    return $var;

}

#-------------------------------------------------------------------

=head2 isFirst ( )

Returns 1 if this is the first of a set of recurring transactions.

=cut

sub isFirst {
    my $self = shift;
	return ($self->get('originatingTransactionId') eq '');
}

#-------------------------------------------------------------------

=head2 isRecurring ( )

Returns 1 if this is a recurring transaction.

=cut

sub isRecurring {
    my $self = shift;
	return $self->get('isRecurring');
}

#-------------------------------------------------------------------

=head2 isSuccessful ( )

Returns 1 if this transaction had a successful payment applied to it.

=cut

sub isSuccessful {
    my $self = shift;
	return $self->get('isSuccessful');
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

=head2 newByGatewayId ( session, gatewayId, payDriverId )

Constructor.  Instanciates a transaction based upon a paymentDriverId and a payment gateway issued id.

=head3 session

A reference to the current session.

=head3 gatewayId

The id the payment gateway has assigned to this transaction. More specifically the value stored in the
transactionCode field.

=head3 payDriverId

The id of the payment driver instance that has processed the transaction.

=cut

sub newByGatewayId {
    my $class       = shift;
    my $session     = shift;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    my $gatewayId   = shift || WebGUI::Error::InvalidParam->throw(error=>"Need a gatewayId.");
    my $payDriverId = shift || WebGUI::Error::InvalidParam->throw(error=>"Need a payDriverId.");

    # Find the transactionId belonging to the gatewayId/payDriverId combo.
    my $transactionId = $session->db->quickScalar(
        'select transactionId from transaction where transactionCode=? and paymentDriverId=?',
        [
            $gatewayId,
            $payDriverId,
        ]
    );

    # Throw an error if there is no such gatewayId/payDriverId combo.
    unless ( $transactionId ) {
        WebGUI::Error::ObjectNotFound->throw(error=>"No such transaction.", id=>$transactionId);
    }

    # We have a transactionId so instanciate it and return the object
    return $class->new( $session, $transactionId );
}

#-------------------------------------------------------------------

=head2 sendNotifications ( transaction )

Sends out a receipt and a sale notification to the buyer and the store owner respectively.

=cut

sub sendNotifications {
    my ($self)  = @_;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'PayDriver');
    my $url     = $session->url;
    my $var     = $self->getTransactionVars;

    # render
    my $template = WebGUI::Asset::Template->new( $session, $session->setting->get("shopReceiptEmailTemplateId") );
    my $inbox    = WebGUI::Inbox->new($session);
    my $receipt  = $template->process( $var );
    WebGUI::Macro::process($session, \$receipt);

    # purchase receipt
    $inbox->addMessage( {
        message     => $receipt,
        subject     => $i18n->get('receipt subject') . ' ' . $self->get('orderNumber'),
        userId      => $self->get('userId'),
        status      => 'completed',
    } );
    
    # shop owner notification
    # Shop owner uses method=view rather than method=viewMy
    $var->{viewDetailUrl} = $url->page( 'shop=transaction;method=view;transactionId='.$self->getId, 1 );
    my $notification      = $template->process( $var );
    WebGUI::Macro::process($session, \$notification);
    $inbox->addMessage( {
        message     => $notification,
        subject     => $i18n->get('a sale has been made') . ' ' . $self->get('orderNumber'),
        groupId     => $session->setting->get('shopSaleNotificationGroupId'),
        status      => 'unread',
    } );
}

#-------------------------------------------------------------------

=head2 thankYou ()

Displays the default thank you page.

=cut

sub thankYou {
    my ($self) = @_;
    my $i18n = WebGUI::International->new($self->session,'Shop');

    my $args     = [$self,$i18n->get('thank you message')];
    my $instance = WebGUI::Content::Account->createInstance($self->session,"shop");
    return $instance->displayContent($instance->callMethod("viewTransaction",$args));
}


#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties in the transaction.

=head3 properties

A hash reference that contains one of the following:

=head4 cart

A reference to a cart object. Will pull shipping method, shipping address, tax, items, and total from
it. Alternatively you can set manually any of the following properties that are set by cart automatically:
amount shippingAddressId shippingAddressName shippingAddress1 shippingAddress2 shippingAddress3 shippingCity
shippingState shippingCountry shippingCode shippingPhoneNumber shippingDriverId shippingDriverLabel shippingPrice
taxes shopCreditDeduction

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

=head4 isRecurring

A boolean indicating whether this is a recurring transaction or not. Defaults to 0.

=head4 originatingTransactionId

Most of the time this will be empty. But if this is a recurring transaction, then this will hold the id of the original transaction that started the recurrence.

=head4 notes

A text field containing notes about this transaction.

=cut

sub update {
    my ($self, $newProperties) = @_;
    my $id = id $self;
    if (exists $newProperties->{cart}) {
        my $cart = $newProperties->{cart};
        $newProperties->{taxes} = $cart->calculateTaxes;

        my $billingAddress = $cart->getBillingAddress;
        $newProperties->{paymentAddressId}   = $billingAddress->getId;
        $newProperties->{paymentAddressName} = $billingAddress->get('firstName') . " " . $billingAddress->get('lastName');
        $newProperties->{paymentAddress1}    = $billingAddress->get('address1');
        $newProperties->{paymentAddress2}    = $billingAddress->get('address2');
        $newProperties->{paymentAddress3}    = $billingAddress->get('address3');
        $newProperties->{paymentCity}        = $billingAddress->get('city');
        $newProperties->{paymentState}       = $billingAddress->get('state');
        $newProperties->{paymentCountry}     = $billingAddress->get('country');
        $newProperties->{paymentCode}        = $billingAddress->get('code');
        $newProperties->{paymentPhoneNumber} = $billingAddress->get('phoneNumber');

        my $shippingAddress = $cart->getShippingAddress;
        $newProperties->{shippingAddressId}   = $shippingAddress->getId;
        $newProperties->{shippingAddressName} = $shippingAddress->get('firstName') . " " . $shippingAddress->get('lastName');
        $newProperties->{shippingAddress1}    = $shippingAddress->get('address1');
        $newProperties->{shippingAddress2}    = $shippingAddress->get('address2');
        $newProperties->{shippingAddress3}    = $shippingAddress->get('address3');
        $newProperties->{shippingCity}        = $shippingAddress->get('city');
        $newProperties->{shippingState}       = $shippingAddress->get('state');
        $newProperties->{shippingCountry}     = $shippingAddress->get('country');
        $newProperties->{shippingCode}        = $shippingAddress->get('code');
        $newProperties->{shippingPhoneNumber} = $shippingAddress->get('phoneNumber');

        if ($cart->requiresShipping) {
            my $shipper = $cart->getShipper;
            $newProperties->{shippingDriverId}    = $shipper->getId;
            $newProperties->{shippingDriverLabel} = $shipper->get('label');
            $newProperties->{shippingPrice}       = $shipper->calculate($cart);
        }
        else {
            $newProperties->{shippingDriverLabel} = "NO SHIPPING";
            $newProperties->{shippingPrice}       = 0;
        }

        $newProperties->{amount}              = $cart->calculateTotal + $newProperties->{shopCreditDeduction};
        $newProperties->{shopCreditDeduction} = $cart->calculateShopCreditDeduction($newProperties->{amount});
        $newProperties->{amount}             += $newProperties->{shopCreditDeduction};

        my $pay = $cart->getPaymentGateway;
        $newProperties->{paymentDriverId}    = $pay->getId;
        $newProperties->{paymentDriverLabel} = $pay->get('label');

        foreach my $item (@{$cart->getItems}) {
            $self->addItem({item=>$item});
        }
    }
    if (exists $newProperties->{paymentMethod}) {
        my $pay = $newProperties->{paymentMethod};
        $newProperties->{paymentDriverId}    = $pay->getId;
        $newProperties->{paymentDriverLabel} = $pay->get('label');
    }
    my @fields = (qw( isSuccessful transactionCode statusCode statusMessage amount shippingAddressId
        shippingAddressName shippingAddress1 shippingAddress2 shippingAddress3 shippingCity shippingState
        shippingCountry shippingCode shippingPhoneNumber shippingDriverId shippingDriverLabel notes
        shippingPrice paymentAddressId paymentAddressName originatingTransactionId isRecurring
        paymentAddress1 paymentAddress2 paymentAddress3 paymentCity paymentState paymentCountry paymentCode
        paymentPhoneNumber paymentDriverId paymentDriverLabel taxes shopCreditDeduction));
    foreach my $field (@fields) {
        $properties{$id}{$field} = (exists $newProperties->{$field}) ? $newProperties->{$field} : $properties{$id}{$field};
    }
    $self->session->db->setRow("transaction","transactionId",$properties{$id});
}

#-------------------------------------------------------------------

=head2 www_cancelRecurring ( )

Cancels a recurring transaction.

=cut

sub www_cancelRecurring {
    my ($class, $session) = @_;
    my $self = $class->new($session, $session->form->get("transactionId"));
    return $session->privilege->insufficient unless (WebGUI::Shop::Admin->new($session)->canManage || $session->user->userId eq $self->get('userId'));
    my $error = $self->cancelRecurring;

    # TODO: Needs to be templated or included in www_view.
    return $error if $error;

    return $class->www_view($session);
}

#-------------------------------------------------------------------

=head2 www_getTransactionsAsJson ()

Retrieves a list of transactions for the www_manage() method.

=cut

sub www_getTransactionsAsJson {
    my ($class, $session) = @_;
    my $admin = WebGUI::Shop::Admin->new($session);
    return $session->privilege->insufficient() unless $admin->canManage;
    my ($db, $form) = $session->quick(qw(db form));
    my $startIndex = $form->get('startIndex') || 0;
    my $numberOfResults = $form->get('results') || 25;
    my @placeholders = ();
    my $sql = 'select SQL_CALC_FOUND_ROWS orderNumber, transactionId, transactionCode, paymentDriverLabel,
        dateOfPurchase, username, amount, isSuccessful, statusCode, statusMessage
        from transaction';
    my $keywords = $form->get("keywords");
    if ($keywords ne "") {
        $db->buildSearchQuery(\$sql, \@placeholders, $keywords, [qw{amount username orderNumber shippingAddressName shippingAddress1 paymentAddressName paymentAddress1}])
    }
    push(@placeholders, $startIndex, $numberOfResults);
    $sql .= ' order by dateOfPurchase desc limit ?,?';
    my %results = ();
    my @records = ();
    my $sth = $db->read($sql, \@placeholders);
	while (my $record = $sth->hashRef) {
		push(@records,$record);
	}
    $results{'recordsReturned'} = $sth->rows()+0;
    $results{'totalRecords'} = $db->quickScalar('select found_rows()') + 0; ##Convert to numeric
    $results{'records'}      = \@records;
    $results{'startIndex'}   = $startIndex;
    $results{'sort'}         = undef;
    $results{'dir'}          = "desc";
    $session->http->setMimeType('application/json');
    return JSON->new->encode(\%results);
}

#-------------------------------------------------------------------

=head2 www_manage ()

Displays a list of all transactions in the system along with management tools for them. 

=cut

sub www_manage {
    my ($class, $session) = @_;
    my $admin = WebGUI::Shop::Admin->new($session);
    return $session->privilege->insufficient() unless $admin->canManage;
    my $i18n = WebGUI::International->new($session, 'Shop');
    my ($style, $url) = $session->quick(qw(style url));
    
    # set up all the files that we need
    $style->setLink($url->extras('/yui/build/fonts/fonts-min.css'), {rel=>'stylesheet', type=>'text/css'});
    $style->setLink($url->extras('/yui/build/datatable/assets/skins/sam/datatable.css'), {rel=>'stylesheet', type=>'text/css'});
    $style->setLink($url->extras('/yui/build/paginator/assets/skins/sam/paginator.css'), {rel=>'stylesheet', type=>'text/css'});
    $style->setScript($url->extras('/yui/build/utilities/utilities.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('/yui/build/json/json-min.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('/yui/build/paginator/paginator-min.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('/yui/build/datasource/datasource-min.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('/yui/build/datatable/datatable-min.js'), {type=>'text/javascript'});

    # draw the html markup that's needed
    $style->setRawHeadTags('<style type="text/css"> #paging a { color: #0000de; } #search form { display: inline; } </style>');
    my $output = q| 

<div class=" yui-skin-sam">
    <div id="search"><form id="keywordSearchForm"><input type="text" name="keywords" id="keywordsField" /><input type="submit" value="|.$i18n->get(364,'WebGUI').q|" /></form></div>
    <div id="paging"></div>
    <div id="dt"></div>
</div>

<script type="text/javascript">
YAHOO.util.Event.onDOMReady(function () {
    var DataSource = YAHOO.util.DataSource,
        Dom        = YAHOO.util.Dom,
        DataTable  = YAHOO.widget.DataTable,
        Paginator  = YAHOO.widget.Paginator;
    |;
    
    # the datasource deals with the stuff returned from www_getTransactionsAsJson
    $output .= "var mySource = new DataSource('".$url->page('shop=transaction;method=getTransactionsAsJson;')."');";
    $output .= <<STOP;
    mySource.responseType   = DataSource.TYPE_JSON;
    mySource.responseSchema = {
        resultsList : 'records',
        fields      : [ 'transactionCode', 'orderNumber', 'paymentDriverLabel',
            'transactionId', 'dateOfPurchase', 'username', 'amount', 'isSuccessful', 'statusCode', 'statusMessage'],
        metaFields: {
            totalRecords: "totalRecords" // Access to value in the server response
        }
    };
STOP


    # create the data table, and a special formatter for the view transaction urls
    $output .= <<STOP;
    var myTableConfig = {
        initialRequest         : 'startIndex=0',
        dynamicData: true, // Enables dynamic server-driven data
        sortedBy : {key:"orderNumber", dir:YAHOO.widget.DataTable.CLASS_DESC}, // Sets UI initial sort arrow
        paginator              : new YAHOO.widget.Paginator({ rowsPerPage:25 })
    };
    formatViewTransaction = function(elCell, oRecord, oColumn, orderNumber) {
STOP
	$output .= q{elCell.innerHTML = '<a href="}.$url->page(q{shop=transaction;method=view})
        .q{;transactionId=' + oRecord.getData('transactionId') + '">' + orderNumber + '</a>'; };
    $output .= '
        }; 
        var myColumnDefs = [
    ';
    $output .= '{key:"orderNumber", label:"'.$i18n->get('order number').'", formatter:formatViewTransaction},';
    $output .= '{key:"dateOfPurchase", label:"'.$i18n->get('date').'",formatter:YAHOO.widget.DataTable.formatDate},';
    $output .= '{key:"username", label:"'.$i18n->get('username').'"},';
    $output .= '{key:"amount", label:"'.$i18n->get('price').'",formatter:YAHOO.widget.DataTable.formatCurrency},';
    $output .= '{key:"statusCode", label:"'.$i18n->get('status code').'"},';
    $output .= '{key:"statusMessage", label:"'.$i18n->get('status message').'"},';
    $output .= '{key:"paymentDriverLabel", label:"'.$i18n->get('payment method').'"}';
    $output .= <<STOP;
    ];
    var myTable = new DataTable('dt', myColumnDefs, mySource, myTableConfig);
    myTable.handleDataReturnPayload = function(oRequest, oResponse, oPayload) {
        oPayload.totalRecords = oResponse.meta.totalRecords;
        return oPayload;
    }
STOP

    # add the necessary event handler to the search button that sends the search request via ajax
    $output .= <<STOP;
    Dom.get('keywordSearchForm').onsubmit = function () {
        var state = myTable.getState();
        state.pagination.recordOffset = 0;
        mySource.sendRequest('keywords=' + Dom.get('keywordsField').value + ';startIndex=0', 
            {success: myTable.onDataReturnInitializeTable, scope:myTable, argument:state});
        return false;
    };
    
     

});
</script>
STOP
    # render everything to a web page
    return $admin->getAdminConsole->render($output, $i18n->get('transactions'));
}


#-------------------------------------------------------------------

=head2 www_manageMy ()

Display a quick list of the user's transactions, with links for more detailed information about
each one in the list.

=cut

sub www_manageMy {
    my ($class, $session) = @_;
    my $instance = WebGUI::Content::Account->createInstance($session,"shop");
    return $instance->displayContent($instance->callMethod("managePurchases"));    
}

#-------------------------------------------------------------------

=head2 www_print ()

Makes transaction information printable.

=cut

sub www_print {
    my ($class, $session) = @_;
    $class->www_view($session, 1);
}

#-------------------------------------------------------------------

=head2 www_refundItem ( )

Refunds a specific item from a transaction and then issues shop credit.

=cut

sub www_refundItem {
    my ($class, $session) = @_;
    return $session->privilege->insufficient unless (WebGUI::Shop::Admin->new($session)->canManage);
    my $form = $session->form;
    my $self = $class->new($session, $form->get("transactionId"));
    my $item = eval { $self->getItem($form->get("itemId")) };
    if (WebGUI::Error->caught()) {
        $session->errorHandler->error("Can't get item ".$form->get("itemId"));
        return $class->www_view($session);
    }
    $item->issueCredit;
    return $class->www_view($session);
}

#-------------------------------------------------------------------

=head2 www_view ()

Displays the admin view of an individual transaction.

=cut

sub www_view {
    my ($class, $session, $print) = @_;
    my $admin = WebGUI::Shop::Admin->new($session);
    return $session->privilege->insufficient() unless $admin->canManage;
    my $i18n = WebGUI::International->new($session, 'Shop');
    my ($style, $url) = $session->quick(qw(style url));
    my $transaction = $class->new($session, $session->form->get('transactionId'));
    
    #render page
    my $output = q{
        <style type="text/css">
            .transactionItems thead th { font-size: 10pt; background-color: #efefef;  margin: 5px; }
            .transactionItems tbody td { font-size: 10pt;  margin: 5px;}
            .transactionDetail {float: left; margin-right: 25px;}
            .transactionDetail th { font-size: 10pt; vertical-align: top; margin-right: 10px; border-right: 1px solid #eeeeee; text-align: left;}
            .transactionDetail td { font-size: 10pt; }
            .smallAddress { font-size: 8pt; }
            .successfulTransaction { color: #008000; }
            .failedTransaction { color: #800000; }
        </style>};
    unless ($print) {
        $output .= q{   
            <div><a href="}.$url->page('shop=transaction;method=print;transactionId='.$transaction->getId).q{">}.$i18n->get('print').q{</a>
            };
        if ($transaction->get('isRecurring')) {
            $output .= q{   
                &bull; <a href="}.$url->page('shop=transaction;method=cancelRecurring;transactionId='.$transaction->getId).q{">}.$i18n->get('cancel recurring transaction').q{</a>
                };
        }
        $output .= q{</div>};
    }
    my $cashier = WebGUI::User->new($session, $transaction->get('cashierUserId'));
    $output .= q{   
        <table class="transactionDetail">
            <tr>
                <th>}. $i18n->get("transaction id") .q{</th><td>}. $transaction->getId . '<br />'. $transaction->get('transactionCode').q{</td>
            </tr>
            <tr>
                <th>}. $i18n->get("order number") .q{</th><td>}. $transaction->get('orderNumber') .q{</td>
            </tr>
            <tr>
                <th>}. $i18n->get("date") .q{</th><td>}. $transaction->get('dateOfPurchase') .q{</td>
            </tr>
            <tr>
                <th>}. $i18n->get("username") .q{</th><td><a href="}.$url->page('op=editUser;uid='.$transaction->get('userId')).q{">}. $transaction->get('username') .q{</a></td>
            </tr>
            <tr>
                <th>}. $i18n->get("cashier") .q{</th><td><a href="}.$url->page('op=editUser;uid='.$cashier->userId).q{">}. $cashier->username .q{</a></td>
            </tr>
            <tr>
                <th>}. $i18n->get("amount") .q{</th><td><b>}. sprintf("%.2f", $transaction->get('amount')) .q{</b></td>
            </tr>
            <tr>
                <th>}. $i18n->get("in shop credit used") .q{</th><td>}. sprintf("%.2f", $transaction->get('shopCreditDeduction')) .q{</td>
            </tr>
            <tr>
                <th>}. $i18n->get("taxes") .q{</th><td>}. sprintf("%.2f", $transaction->get('taxes')) .q{</td>
            </tr>
    };
    unless ($print) {
        $output .= q{
            <tr>
                <th>}. $i18n->get("notes") .q{</th><td>}
                .WebGUI::Form::formHeader($session)
                .WebGUI::Form::hidden($session, {name=>"shop",value=>"transaction"})
                .WebGUI::Form::hidden($session, {name=>"method",value=>"update"})
                .WebGUI::Form::hidden($session, {name=>"transactionId",value=>$transaction->getId})
                .WebGUI::Form::textarea($session, {name=>"notes", value=>$transaction->get('notes')})
                .'<br />'
                .WebGUI::Form::submit($session, {value=>$i18n->get('update'), extras=>' '})
                .WebGUI::Form::formFooter($session)
                .q{</td>
            </tr>
        };
    }
    $output .= q{
        </table>
        <table class="transactionDetail">
            <tr>
                <th>}. $i18n->get("shipping method") .q{</th><td><a href="}.$url->page('shop=ship;method=do;do=edit;driverId='.$transaction->get('shippingDriverId')).q{">}. $transaction->get('shippingDriverLabel') .q{</a></td>
            </tr>
            <tr>
                <th>}. $i18n->get("shipping amount") .q{</th><td>}. sprintf("%.2f", $transaction->get('shippingPrice')) .q{</td>
            </tr>
            <tr>
                <th>}. $i18n->get("shipping address") .q{</th><td>}. $transaction->formatAddress({
                        name        => $transaction->get('shippingAddressName'),
                        address1    => $transaction->get('shippingAddress1'),
                        address2    => $transaction->get('shippingAddress2'),
                        address3    => $transaction->get('shippingAddress3'),
                        city        => $transaction->get('shippingCity'),
                        state       => $transaction->get('shippingState'),
                        code        => $transaction->get('shippingCode'),
                        country     => $transaction->get('shippingCountry'),
                        phoneNumber => $transaction->get('shippingPhoneNumber'),
                        }) .q{</td>
            </tr>
            <tr>
                <th>}. $i18n->get("payment method") .q{</th><td><a href="}.$url->page('shop=pay;method=do;do=edit;paymentGatewayId='.$transaction->get('paymentDriverId')).q{">}. $transaction->get('paymentDriverLabel') .q{</a></td>
            </tr>
            <tr>
                <th>}. $i18n->get("status message") .q{</th><td class="}.(($transaction->get("isSuccessful")) ? 'successfulTransaction' : 'failedTransaction' ).q{">}. $transaction->get('statusCode') .': '.$transaction->get('statusMessage').q{</td>
            </tr>
            <tr>
                <th>}. $i18n->get("payment address") .q{</th><td>}. $transaction->formatAddress({
                        name        => $transaction->get('paymentAddressName'),
                        address1    => $transaction->get('paymentAddress1'),
                        address2    => $transaction->get('paymentAddress2'),
                        address3    => $transaction->get('paymentAddress3'),
                        city        => $transaction->get('paymentCity'),
                        state       => $transaction->get('paymentState'),
                        code        => $transaction->get('paymentCode'),
                        country     => $transaction->get('paymentCountry'),
                        phoneNumber => $transaction->get('paymentPhoneNumber'),
                        }) .q{</td>
            </tr>
        </table>
        <div style="clear:both;"></div>
    };
    
    # item detail
    $output .= q{
     <table class="transactionItems">
        <thead>
            <tr>
            <th>}.$i18n->get('date').q{</th>
            <th>}.$i18n->get('item').q{</th>
            <th>}.$i18n->get('price').q{</th>
            <th>}.$i18n->get('quantity').q{</th>
            <th>}.$i18n->get('shipping address').q{</th>
            <th>}.$i18n->get('order status').q{</th>
            <th>}.$i18n->get('tracking number').q{</th>
            <th>}.$i18n->get('manage').q{</th>
            </tr>
        </thead>
        <tbody>
    };
    foreach my $item (@{$transaction->getItems}) {
        $output .= WebGUI::Form::formHeader($session)
            .WebGUI::Form::hidden($session, {name=>"shop",value=>"transaction"})
            .WebGUI::Form::hidden($session, {name=>"method",value=>"updateItem"})
            .WebGUI::Form::hidden($session, {name=>"transactionId",value=>$transaction->getId})
            .WebGUI::Form::hidden($session, {name=>"itemId",value=>$item->getId})
            .q{
            <tr>
            <td>}.$item->get('lastUpdated').q{</td>
            <td><a href="}.$url->page('shop=transaction;method=viewItem;transactionId='.$transaction->getId.';itemId='.$item->getId).q{">}.$item->get('configuredTitle').q{</a></td>
            <td>}.$transaction->formatCurrency($item->get('price')).q{</td>
            <td>}.$item->get('quantity').q{</td>
        };
        if ($item->get('shippingAddressId') eq $transaction->get('shippingAddressId')) {
            $output .= q{<td></td>};
        }
        else {
            $output .= q{
                <td class="smallAddress">}. $transaction->formatAddress({
                            name        => $item->get('shippingAddressName'),
                            address1    => $item->get('shippingAddress1'),
                            address2    => $item->get('shippingAddress2'),
                            address3    => $item->get('shippingAddress3'),
                            city        => $item->get('shippingCity'),
                            state       => $item->get('shippingState'),
                            code        => $item->get('shippingCode'),
                            country     => $item->get('shippingCountry'),
                            phoneNumber => $item->get('shippingPhoneNumber'),
                            }) .q{</td>
            };
        }
        if ($item->get('orderStatus') eq 'Cancelled') {
            $output .= q{<td>}.$i18n->get($item->get('orderStatus')).q{</td><td></td><td></td>};
        }
        else {
            $output .= q{<td>}.WebGUI::Form::selectBox($session, {
                name        => "orderStatus",
                value       => $item->get('orderStatus'),
                options     => {
                    NotShipped  => $i18n->get('NotShipped'),
                    Shipped     => $i18n->get('Shipped'),
                    Backordered => $i18n->get('Backordered'),
                    },
                })
                .q{</td>}
                .q{<td>}
                .WebGUI::Form::text($session, {name=>"shippingTrackingNumber", size=>15, value=>$item->get('shippingTrackingNumber')})
                .q{</td><td>}
                .WebGUI::Form::submit($session, {value=>$i18n->get('update'), extras=>' '})
                .WebGUI::Form::submit($session, {value=>$i18n->get('refund'), extras=>q|onclick="this.form.method.value='refundItem'"|})
                .q{</td>};
        }
        $output .= q{
                </tr>
            </form>
        };
    }
    $output .= q{
        </tbody>
        </table>
    };
    
    # send output
    if ($print) {
        return $output;   
    }
    return $admin->getAdminConsole->render($output, $i18n->get('transactions'));
}


#-------------------------------------------------------------------

=head2 www_viewItem ( )

Displays the configured item.

=cut

sub www_viewItem {
    my ($class, $session) = @_;
    my $self = $class->new($session, $session->form->get("transactionId"));
    my $item = eval { $self->getItem($session->form->get("itemId")) };
    if (WebGUI::Error->caught()) {
        $session->errorHandler->error("Can't get item ".$session->form->get("itemId"));
        return $class->www_view($session);
    }
    return $item->getSku->www_view;
}

#-------------------------------------------------------------------

=head2 www_viewMy ()

Displays transaction detail for a user's purchase.

=cut

sub www_viewMy {
    my ($class, $session, $transaction, $notice) = @_;

    my $args     = [$transaction,$notice];
    my $instance = WebGUI::Content::Account->createInstance($session,"shop");
    return $instance->displayContent($instance->callMethod("viewTransaction",$args));
}

#-------------------------------------------------------------------

=head2 www_update ( )

Sets the properties for the transaction, specifically "notes".

=cut

sub www_update {
    my ($class, $session) = @_;
    return $session->privilege->insufficient unless (WebGUI::Shop::Admin->new($session)->canManage);
    my $self = $class->new($session, $session->form->get("transactionId"));
    my $form = $session->form;
    $self->update({
        notes  => $form->get('notes'),
        });
    return $class->www_view($session);
}

#-------------------------------------------------------------------

=head2 www_updateItem ( )

Sets the order status and tracking number.

=cut

sub www_updateItem {
    my ($class, $session) = @_;
    return $session->privilege->insufficient unless (WebGUI::Shop::Admin->new($session)->canManage);
    my $self = $class->new($session, $session->form->get("transactionId"));
    my $form = $session->form;
    my $item = eval { $self->getItem($form->get("itemId")) };
    if (WebGUI::Error->caught()) {
        $session->errorHandler->error("Can't get item ".$form->get("itemId"));
        return $class->www_view($session);
    }
    $item->update({
        orderStatus             => $form->get('orderStatus'),
        shippingTrackingNumber  => $form->get('shippingTrackingNumber'),
        });
    return $class->www_view($session);
}

1;
