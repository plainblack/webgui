package WebGUI::Shop::PayDriver::Ogone;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;

use WebGUI::Shop::PayDriver;
use WebGUI::Exception;
use Digest::SHA qw{ sha1_hex };
use WebGUI::International;
use Data::Dumper;

use base qw{ WebGUI::Shop::PayDriver };

#-------------------------------------------------------------------

=head2 canCheckoutCart ( )

Returns whether the cart can be checked out by this plugin.

=cut

sub canCheckoutCart {
    my $self    = shift;
    my $cart    = $self->getCart;

    return 0 unless $cart->readyForCheckout;
    return 0 if $cart->requiresRecurringPayment;

    return 1;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Shop::PayDriver->definition.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;

    WebGUI::Error::InvalidParam->throw( error => q{Must provide a session variable} )
        unless $session && ref $session eq 'WebGUI::Session';

    my $i18n = WebGUI::International->new($session, 'PayDriver_Ogone');

    tie my %fields, 'Tie::IxHash';
    
    %fields = (
		pspid => {
		    fieldType       => 'text',
		    label           => $i18n->get('psp id'),
		    hoverHelp       => $i18n->get('psp id help'),
		    defaultValue    => '',
		},
        shaSecret => {
            fieldType       => 'password',
            label           => $i18n->get('sha secret'),
            hoverHelp       => $i18n->get('sha secret help'),
        },
        postbackSecret  => {
            fieldType       => 'password',
            label           => $i18n->get('postback secret'),
            hoverHelp       => $i18n->get('postback secret help'),
        },
        locale => {
            fieldType       => 'text',
            label           => $i18n->get('locale'),
            hoverHelp       => $i18n->get('locale help'),
            defaultValue    => 'en_US',
            maxlength       => 5,
            size            => 5,
        },
        currency => {
            fieldType       => 'text',
            label           => $i18n->get('currency'),
            hoverHelp       => $i18n->get('currency help'),
            defaultValue    => 'EUR',
            maxlength       => 3,
            size            => 3,
        },
        useTestMode => {
            fieldType       => 'yesNo',
            label           => $i18n->get('use test mode'),
            hoverHelp       => $i18n->get('use test mode help'),
            defaultValue    => 1,
        },
    );

    push @{ $definition }, {
	    name        => $i18n->get('Ogone'),
    	properties  => \%fields,
    };

    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getButton ( )

Returns the HTML for a form containing a button that, when clicked, will take the user to the checkout screen of
this plugin.

=cut

sub getButton {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'PayDriver_Ogone');

    my $payForm = WebGUI::Form::formHeader($session)
        . $self->getDoFormTags('getCredentials')
        . WebGUI::Form::submit($session, {value => $i18n->get('Ogone') })
        . WebGUI::Form::formFooter($session);

    return $payForm;
}

#-------------------------------------------------------------------

=head2 getCart 

Returns the cart for either the current user or the transaction passed back by Ogone.

=cut

sub getCart {
    my $self = shift;
    my $cart;

    if ($self->{_cartId}) {
        $cart = WebGUI::Shop::Cart->new( $self->session, $self->{_cartId} );
    }

    return $cart || $self->SUPER::getCart;
}

#-------------------------------------------------------------------

=head2 processPayment ()

See WebGUI::Shop::PayDriver->processPayment

=cut

sub processPayment {
    my $self = shift;
    # Since we'll have to create a transaction before doing the actual tranasction, we let it fail
    # initially with a message that it is pending.
    # Unless the transaction result with _setPaymentStatus the transaction will fail.
    
    my $success = $self->{_transactionSuccessful}   || 0;
    my $id      = $self->{_ogoneId}                 || undef;
    my $status  = $self->{_statusCode}              || undef;
    my $message = $self->{_statusMessage}           || 'Waiting for checkout';

    return ( $success, $id, $status, $message );
    return (0, undef, 1, 'Pending');
}

#-------------------------------------------------------------------

=head2 ogoneCheckoutButton ( transaction, address )

Generates a form with a submit button that, when clicked, posts the payment data for the given transaction to Ogone
and takes the user there.

=head3 transaction

The instanciated transaction that should be paid.

=head3 address

An instanciated WebGUI::Shop::Address object that contains the billing address.

=cut

sub ogoneCheckoutButton {
	my $self        = shift;
    my $transaction = shift;
    my $address     = shift;
	my $session     = $self->session;
    my $i18n        = WebGUI::International->new( $session, 'PayDriver_Ogone' );

	$self->{ _ogoneTransaction } = "done" ;
    
    # Ogone needs the transaction amount in cents
    my $amount  = sprintf( "%.2f", $transaction->get('amount') ) * 100;
    $amount     =~ s/[^\d]//g;              # Remove any character from amount except digits.

    my $orderId     = $transaction->getId;
	my $description = "Transaction ID: $orderId";
	my $pspId       = $self->get('pspid');
	my $name    	= join " ", $address->get( 'firstName' ), $address->get( 'lastName' );
	my $email 		= $address->get('email');

    my $currency    = $self->get('currency');

    # Generate sha signature the payment data
    my $passphrase      = join '', $orderId, $amount, $currency, $pspId, $self->get('shaSecret');
    my $shaSignature    = uc sha1_hex( $passphrase ); 

    # Define the data to be sent to ogone
    my %parameters  = (
        PSPID           => $pspId,
        orderID         => $orderId,
        amount          => $amount,
        currency        => $currency,
        language        => $self->get('locale'),
        CN              => join( " ", $address->get('firstName'), $address->get('lastName') ),
        EMAIL           => $email,
        ownerZIP        => $address->get( 'code' ),
        owneraddress    => join( " ", $address->get('address1'), $address->get('address2'), $address->get('address3') ),
        ownercty        => $address->get('country'),
        ownertown       => $address->get('city'),
        ownertelno      => $address->get('phoneNumber'),
        COMPLUS         => $self->getCart->getId,
        COM             => $description,
        SHASign         => $shaSignature,
        accepturl       =>
            $self->session->url->getSiteURL.'/?shop=pay&method=do&do=acceptTransaction&paymentGatewayId='.$self->getId,
        cancelurl       => 
            $self->session->url->getSiteURL.'/?shop=pay&method=do&do=cancelTransaction&paymentGatewayId='.$self->getId,
        declineurl      =>
            $self->session->url->getSiteURL.'/?shop=pay&method=do&do=declineTransaction&paymentGatewayId='.$self->getId,
        exceptionurl    =>
            $self->session->url->getSiteURL.'/?shop=pay&method=do&do=exceptionTransaction&paymentGatewayId='.$self->getId
    );

    # Convert payment data to hidden input tags
    my $formFields = 
        join    "\n",
        map     { WebGUI::Form::hidden( $session, { name => $_, value => $parameters{ $_ } } ) }
        keys    %parameters;

    # Construct actual checkout form
    
    my $action  = $self->get('useTestMode')
                ? 'https://secure.ogone.com/ncol/test/orderstandard.asp'
                : 'https://secure.ogone.com/ncol/prod/orderstandard.asp'
                ;

    my $form    = 
        WebGUI::Form::formHeader( $session, { 
            action  => $action, 
            method  => 'POST', 
            enctype => 'application/x-www-form-urlencoded',
        } )
        . $formFields
        . WebGUI::Form::submit( $session, { name => 'submit2', value   => $i18n->get('pay') } )
        . WebGUI::Form::formFooter( $session );

	return $form;
}

#-------------------------------------------------------------------

=head2 www_getCredentials ( [ addressId ] )

Displays the checkout form for this plugin.

=head3 addressId

Optionally supply this variable which will set the payment address to this addressId.

=cut

sub www_getCredentials {
    my ($self, $addressId)    = @_;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new( $session, 'PayDriver_Ogone' );

    # Process address from address book if passed
    $addressId   = $session->form->process( 'addressId' );
    my $address;
    if ( $addressId ) {
        $address    = eval{ $self->getAddress( $addressId ) };
    }
    else { 
        $address    = $self->getCart->getShippingAddress;
    }
    my $billingAddressHtml = $address->getHtmlFormatted;

    # Fetch transaction
    my $transactionId = $session->form->process('transactionId');
    my $transaction;
    if ($transactionId) {
        $transaction = WebGUI::Shop::Transaction->new( $session, $transactionId );
    }

    # Or generate a new one
    unless ($transaction) {
        $transaction = $self->processTransaction( $address );
    }

    # Set the billing address
    $transaction->update( {
        paymentAddress  => $address,
    } );

    # Generate the json string that defines where the address book posts the selected address
    my $callbackParams = {
        url     => $session->url->page,
        params  => [
            { name => 'shop',               value => 'pay' },
            { name => 'method',             value => 'do' },
            { name => 'do',                 value => 'getCredentials' },
            { name => 'paymentGatewayId',   value => $self->getId },
        ],
    };
    my $callbackJson = JSON::to_json( $callbackParams );

    # Generate 'Choose billing address' button
    my $addressButton = WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { name => 'shop',     value => 'address' } )
        . WebGUI::Form::hidden( $session, { name => 'method',   value => 'view' } )
        . WebGUI::Form::hidden( $session, { name => 'callback', value => $callbackJson } )
        . WebGUI::Form::submit( $session, { value => $i18n->get('choose billing address') } )
        . WebGUI::Form::formFooter( $session);


    # Generate 'Proceed' button
    my $proceedButton = $address 
                      ? $self->ogoneCheckoutButton( $transaction, $address ) 
                      : $i18n->get('please choose a billing address')
                      ;
    return $session->style->userStyle($addressButton.'<br />'.$billingAddressHtml.'<br />'.$proceedButton);
}

#-------------------------------------------------------------------

=head2 checkPostbackSHA ( )

Processes the postback data Ogone sends after a payment/cancelation. Figures out which transaction the data belongs
to and checks whether the data isn't tampered with by comparing SHA hashes.

If everything checks out, returns the instanciated transaction object, otherwise returns undef.

=cut

sub checkPostbackSHA {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my $url     = $session->url;

    # Instanciate transaction
    my $transactionId   = $url->unescape( $form->process( 'orderID' ) );
    my $transaction     = WebGUI::Shop::Transaction->new( $session, $transactionId );
    return undef unless $transaction;

    # Fetch and format amount from transaction
    my $amount      = $transaction->get('amount');
    $amount         =~ s/\.00$//;                 # remove trailing .00
    my $currency    = $self->get('currency');

    # Construct the passphrase...
    my $passphrase  = join '', 
        $transactionId, $currency, $amount, 
        map( { $url->unescape( $form->process( $_ ) ) } qw{ PM ACCEPTANCE STATUS CARDNO PAYID NCERROR BRAND } ),
        $self->get('postbackSecret');

    # and obtain its sha-1 hash in uppercase
    my $shaSignature    = uc sha1_hex( $passphrase ); 

    # Return the instanciated transaction if the hash is valid, else return undef.
    return $transaction if $shaSignature eq $form->process('SHASIGN');
    return undef;
}

#-------------------------------------------------------------------

=head2 _setPaymentStatus ( transactionSuccessful, ogoneId, statusCode, statusMessage )

Stores the results of a postback in the object for later use by other methods.

=head3 transactionSuccessful

A boolean indicating whether or not the payment was successful.

=head3 ogoneId

The Ogone issued transaction ID.

=head3 statusCode

The Ogone issued status code.

=head3 statusMessage

The ogone issued status message.

=cut

sub _setPaymentStatus {
    my $self = shift;
    my ($form, $url) = $self->session->quick( 'form', 'url' );

    $self->{_transactionSuccessful} = shift || 0;
    $self->{_ogoneId}               = shift || undef;
    $self->{_statusCode}            = shift || undef;
    $self->{_statusMessage}         = shift || undef;

    $self->{_cartId}                = $url->unescape( $form->process('COMPLUS') );
}

#-------------------------------------------------------------------

=head2 www_acceptTransaction ( )

The user is redirected to this screen when the payment was successful.

=cut

sub www_acceptTransaction {
    my $self = shift;
    my $session = $self->session;
    my $form    = $session->form;

    my $transaction = $self->checkPostbackSHA;
    return $session->style->userStyle('Invalid postback data.') unless $transaction;

    if ( $form->process('NCERROR') == 0 ) {
        if ( !$transaction->isSuccessful ) {
            $self->_setPaymentStatus( 1, $form->process('PAYID'), $form->process('STATUS'), 'Complete' );
            $self->processTransaction( $transaction );
        }
        return $transaction->thankYou;
    }

    return $session->style->userStyle( 'An error occurred with your transaction.' );
}

#-------------------------------------------------------------------

=head2 www_cancelTransaction ( )

The user is redirected to this screen when the payment was canceled.

=cut

sub www_cancelTransaction {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;

    my $transaction = $self->checkPostbackSHA;
    return $session->style->userStyle('Invalid postback data.') unless $transaction;

    $self->_setPaymentStatus( 0, $form->process('PAYID'), $form->process('STATUS'), 'Cancelled' );
    $self->processTransaction( $transaction );

    $session->http->setRedirect($self->session->url->getSiteURL.'?shop=cart');
    return $session->style->userStyle('Transaction cancelled');
}

#-------------------------------------------------------------------

=head2 www_declineTransaction ( )

The user is redirected to this screen when the payment was declined.

=cut

sub www_declineTransaction {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;

    my $transaction = $self->checkPostbackSHA;
    return $session->style->userStyle('Invalid postback data.') unless $transaction;

    $self->_setPaymentStatus( 0, $form->process('PAYID'), $form->process('STATUS'), 'Declined' );
    $self->processTransaction( $transaction );

    $session->http->setRedirect($self->session->url->getSiteURL.'?shop=cart');
    return $session->style->userStyle('Transaction declined');
}

#-------------------------------------------------------------------

=head2 www_exceptionTransaction ( ) 

The user is redirected to this screen when a payment exception occurred.

=cut

sub www_exceptionTransaction {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;

    my $transaction = $self->checkPostbackSHA;
    return $session->style->userStyle('Invalid postback data.') unless $transaction;

    $self->_setPaymentStatus( 0, $form->process('PAYID'), $form->process('STATUS'), 'Transaction exception occurred' );
    $self->processTransaction( $transaction );

    $session->http->setRedirect($self->session->url->getSiteURL.'?shop=cart');
    return $session->style->userStyle('A transaction exception occurred.');
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Displays the properties screen.


=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    my $admin   = WebGUI::Shop::Admin->new($session);
    my $i18n    = WebGUI::International->new($session, 'PayDriver_Ogone');

    return $session->privilege->insufficient() unless $admin->canManage;

    my $form = $self->getEditForm;
    $form->submit;

    my $processUrl = $self->session->url->getSiteURL.'/?shop=pay&method=do&do=processTransaction&paymentGatewayId='.$self->getId;
    my $output = '<br />';
    $output .= sprintf $i18n->get('ogone setup'), $processUrl, $processUrl;
        
    return $admin->getAdminConsole->render($form->print.$output, $i18n->get('payment methods','PayDriver'));
}

#-------------------------------------------------------------------

=head2 www_processTransaction ( )

This method is called by the post sale notfication.

=cut

sub www_processTransaction {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;

    my $transaction = $self->checkPostbackSHA;
    return $session->style->userStyle('Invalid postback data.') unless $transaction;

    if ( $form->process('NCERROR') == 0 ) {
        if ( !$transaction->isSuccessful ) {
            $self->_setPaymentStatus( 1, $form->process('PAYID'), $form->process('STATUS'), 'Complete' );
        }
    }
    else {
        $self->_setPaymentStatus( 0, $form->process('PAYID'), $form->process('STATUS'), 'A payment processing error occurred' );
    }

    $self->processTransaction( $transaction );

    return 'ok';
}

1;

