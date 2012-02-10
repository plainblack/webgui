package WebGUI::Shop::PayDriver::Ogone;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

use Moose;
use WebGUI::Definition::Shop;
extends 'WebGUI::Shop::PayDriver';
define pluginName => [qw/Ogone PayDriver_Ogone/];
property pspid => (
            fieldType       => 'text',
            label           => ['psp id', 'PayDriver_Ogone'],
            hoverHelp       => ['psp id help', 'PayDriver_Ogone'],
            default         => '',
         );
property shaSecret => (
            fieldType       => 'password',
            label           => ['sha secret', 'PayDriver_Ogone'],
            hoverHelp       => ['sha secret help', 'PayDriver_Ogone'],
         );
property postbackSecret => (
            fieldType       => 'password',
            label           => ['postback secret', 'PayDriver_Ogone'],
            hoverHelp       => ['postback secret help', 'PayDriver_Ogone'],
         );
property locale => (
            fieldType       => 'text',
            label           => ['locale', 'PayDriver_Ogone'],
            hoverHelp       => ['locale help', 'PayDriver_Ogone'],
            default         => 'en_US',
            maxlength       => 5,
            size            => 5,
         );
property currency => (
            fieldType       => 'text',
            label           => ['currency', 'PayDriver_Ogone'],
            hoverHelp       => ['currency help', 'PayDriver_Ogone'],
            default         => 'EUR',
            maxlength       => 3,
            size            => 3,
         );
property useTestMode => (
            fieldType       => 'yesNo',
            label           => ['use test mode', 'PayDriver_Ogone'],
            hoverHelp       => ['use test mode help', 'PayDriver_Ogone'],
            default         => 1,
         );
property summaryTemplateId => (
            fieldType    => 'template',
            label        => ['summary template', 'PayDriver_Ogone'],
            hoverHelp    => ['summary template help', 'PayDriver_Ogone'],
            namespace    => 'Shop/Credentials',
            default      => 'jysVZeUR0Bx2NfrKs5sulg',
         );

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

=head2 getCart 

Overrides the base method to use the locally cached cardId.

=cut

override getCart => sub {
    my $self = shift;
    my $cart;

    if ($self->{_cartId}) {
        $cart = WebGUI::Shop::Cart->new( $self->session, $self->{_cartId} );
    }

    return $cart || super();
};

#-------------------------------------------------------------------

=head2 processPayment ()

See WebGUI::Shop::PayDriver->processPayment

=cut

sub processPayment {
    my $self = shift;
    # Since we'll have to create a transaction before doing the actual tranasction, we let it fail
    # initially with a message that it is pending.
    # Unless the transaction result is updated via _setPaymentStatus the transaction will fail.
    
    my $success = $self->{_transactionSuccessful}   || 0;
    my $id      = $self->{_ogoneId}                 || undef;
    my $status  = $self->{_statusCode}              || undef;
    my $message = $self->{_statusMessage}           || 'Waiting for checkout';

    return ( $success, $id, $status, $message );
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
	my $pspId       = $self->pspid;
	my $name    	= join " ", $address->get( 'firstName' ), $address->get( 'lastName' );
	my $email 		= $address->get('email');

    my $currency    = $self->currency;

    # Generate sha signature the payment data
    my $passphrase      = join '', $orderId, $amount, $currency, $pspId, $self->shaSecret;
    my $shaSignature    = uc sha1_hex( $passphrase ); 

    # Define the data to be sent to ogone
    my %parameters  = (
        PSPID           => $pspId,
        orderID         => $orderId,
        amount          => $amount,
        currency        => $currency,
        language        => $self->locale,
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
    
    my $action  = $self->useTestMode
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
    my $currency    = $self->currency;

    # Construct the passphrase...
    my $passphrase  = join '', 
        $transactionId, $currency, $amount, 
        map( { $url->unescape( $form->process( $_ ) ) } qw{ PM ACCEPTANCE STATUS CARDNO PAYID NCERROR BRAND } ),
        $self->postbackSecret;

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

    $session->response->setRedirect($self->session->url->getSiteURL.'?shop=cart');
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

    $session->response->setRedirect($self->session->url->getSiteURL.'?shop=cart');
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

    $session->response->setRedirect($self->session->url->getSiteURL.'?shop=cart');
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
    $form->addField( 'csrfToken', name => 'csrfToken' );
    $form->addField( "submit", name => "send" );

    my $processUrl = $self->session->url->getSiteURL.'/?shop=pay&method=do&do=processTransaction&paymentGatewayId='.$self->getId;
    my $output = '<br />';
    $output .= sprintf $i18n->get('ogone setup'), $processUrl, $processUrl;
        
    return $admin->getAdminConsole->render($form->print.$output, $i18n->get('payment methods','PayDriver'));
}

#-------------------------------------------------------------------

=head2 www_getCredentials ( )

Displays the checkout form for this plugin.

=cut

sub www_getCredentials {
    my ($self)    = @_;
    my $session = $self->session;

    # Fetch transaction
    my $transactionId = $session->form->process('transactionId');
    my $transaction;
    if ($transactionId) {
        $transaction = WebGUI::Shop::Transaction->new( $session, $transactionId );
    }

    # Or generate a new one
    unless ($transaction) {
        $transaction = $self->processTransaction( );
    }

    # Generate 'Proceed' button
    my $var = {
        proceedButton => $self->ogoneCheckoutButton,
    };
    $self->appendCartVariables($var);

    my $output = $self->processTemplate($self->summaryTemplateId, $var);
    return $session->style->userStyle($output);
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

