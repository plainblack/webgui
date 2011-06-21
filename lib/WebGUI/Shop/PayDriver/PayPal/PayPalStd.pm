package WebGUI::Shop::PayDriver::PayPal::PayPalStd;

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

use URI;
use URI::Escape;
use LWP::UserAgent;
use Readonly;
use WebGUI::Shop::Transaction;

Readonly my $I18N => 'PayDriver_PayPalStd'; 

use Moose;
use WebGUI::Definition::Shop;
extends qw/WebGUI::Shop::PayDriver::PayPal/;

define pluginName => [qw/PayPal PayDriver_PayPalStd/];
property vendorId => (
            fieldType => 'text',
            label     => ['vendorId', 'PayDriver_PayPalStd'],
            hoverHelp => ['vendorId help', 'PayDriver_PayPalStd'],
         );
property signature => (
            fieldType => 'textarea',
            label     => ['signature', 'PayDriver_PayPalStd'],
            hoverHelp => ['signature help', 'PayDriver_PayPalStd'],
         );
property identityToken => (
            fieldType => 'text',
            label     => ['identity token', 'PayDriver_PayPalStd'],
            hoverHelp => ['identity token help', 'PayDriver_PayPalStd'],
         );
property currency => (
            fieldType    => 'selectBox',
            label        => ['currency', 'PayDriver_PayPalStd'],
            hoverHelp    => ['currency help', 'PayDriver_PayPalStd'],
            default      => 'USD',
            options      => \&_currency_options,
         );
sub _currency_options {
    my $self = shift;
    return $self->getPaymentCurrencies();
}
property useSandbox => (
            fieldType    => 'yesNo',
            label        => ['use sandbox', 'PayDriver_PayPalStd'],
            hoverHelp    => ['use sandbox help', 'PayDriver_PayPalStd'],
            default      => 1,
         );
property sandboxUrl => (
            fieldType    => 'text',
            label        => ['sandbox url', 'PayDriver_PayPalStd'],
            hoverHelp    => ['sandbox url help', 'PayDriver_PayPalStd'],
            default      => 'https://www.sandbox.paypal.com/cgi-bin/webscr',
         );
property liveUrl => (
            fieldType    => 'text',
            label        => ['live url', 'PayDriver_PayPalStd'],
            hoverHelp    => ['live url help', 'PayDriver_PayPalStd'],
            default      => 'https://www.paypal.com/cgi-bin/webscr',
         );
property buttonImage => (
            fieldType    => 'text',
            label        => ['button image', 'PayDriver_PayPalStd'],
            hoverHelp    => ['button image help', 'PayDriver_PayPalStd'],
            default      => '',
         );
property summaryTemplateId => (
            fieldType    => 'template',
            label        => ['summary template', 'PayDriver_PayPalStd'],
            hoverHelp    => ['summary template help', 'PayDriver_PayPalStd'],
            namespace    => 'Shop/Credentials',
            default      => '',
         );

=head1 NAME

PayPal Website payments standard

=head1 DESCRIPTION

A PayPal Website payments standard handler for WebGUI. Provides an interface to PayPal with cart contents
and transaction information on return.

=head2 IMPORTANT NOTE

In order to use this module, Auto Return and PDT must be enabled in your
paypal seller account.  If they are not, everything will break!

=head1 SYNOPSIS

 Add "WebGUI::Shop::PayDriver::PayPal::PayPalStd" to the paymentDrivers list in your WebGUI site config file.
 Re-start the WebGUI modperl and modproxy web servers.

=cut

#-------------------------------------------------------------------
# local subs

#-------------------------------------------------------------------

=head2 handlesRecurring

Tells the commerce system that this payment plugin can handle recurring payments.
1 = yes, 0 = no. This module == no.

=cut

sub handlesRecurring { 0 }

#-------------------------------------------------------------------

# Recurring TX stuff removed, for now.

#-------------------------------------------------------------------

=head2 getButton 

Extends the base class to add a user configurable button image.

=cut

sub getButton {
    my $self    = shift;
    my $session = $self->session;
    
    my $header = WebGUI::Form::formHeader(
        $session, {
            action => $self->payPalUrl, 
            method => 'POST',
        }
    );

    # All the API stuff is done in paymentVariables; we'll just turn it into
    # hidden form fields here
    my $v           = $self->paymentVariables;
    my $transaction = $self->processTransaction();
    $v->{custom}    = $transaction->getId;
    my $fields = join "\n", map {
        WebGUI::Form::hidden( $session, { name => $_, value => $v->{$_} } )
    } (keys %$v);

    # Customized buttons are allowed; If they didn't give us one, we'll just
    # do a submit button with i18n'd paypal text.  If they did, we'll use an
    # image submit.
    my $button;
    my $i18n = WebGUI::International->new( $session, 'PayDriver_PayPalStd' );
    my $text = $i18n->get('PayPal');
    if ( $self->buttonImage ) {
        my $raw = $self->buttonImage;
        WebGUI::Macro::process( $session, \$raw );
        $button = qq{
            <input type='image' 
                   src='$raw' 
                   border='0' 
                   name='submit'
                   alt='$text'>
        };
    }
    else {
        $button = WebGUI::Form::submit( $session, { value => $text } );
    }

    my $footer = WebGUI::Form::formFooter($session);
    return join "\n", $header, $fields, $button, $footer;
}

#-------------------------------------------------------------------

=head2 getPayPalParams

Using the tx form variable, dial up PayPal and ask them for details about the transaction.
Return a hashreference of name/value pairs, along with PAYPAL_TX, the transactionId and
PAYPAL_REQUEST_STATUS, the HTTP code from the response from PayPal.

=cut

sub getPayPalParams {
    my $self    = shift;
    my $session = $self->session;
    # instead of relying on what was passed to us.
    return $self->{_params} if $self->{_params};
    my $tx = $session->form->process('tx');

    my %form = (
        cmd => '_notify-synch',
        tx  => $tx,
        at  => $self->identityToken,
    );
    my $response = LWP::UserAgent->new->post($self->payPalUrl, \%form);
    my ($status, @lines) = split("\n", $response->content);
    my %params = map { split /=/ }
                 map { uri_unescape($_) } @lines;
    $params{PAYPAL_REQUEST_STATUS} = $status;
    $params{PAYPAL_TX} = $tx;
    $self->{_params} = \%params;
    return $self->{_params};
}

#-------------------------------------------------------------------

=head2 paymentVariables

Returns a hashref of the payment variables to be used as hidden form fields
when clicking the getButton button.

=cut

sub paymentVariables {
    my $self = shift;
    my $url  = $self->session->url;
    my $base = $url->getSiteURL . $url->page;
    my $cart = $self->getCart;
    my $i18n = WebGUI::International->new($self->session);

    my $return = URI->new($base);
    $return->query_form( {
            shop             => 'pay',
            method           => 'do',
            do               => 'completeTransaction',
            paymentGatewayId => $self->getId,
        }
    );

    my $cancel = URI->new($base);
    $cancel->query_form({ shop => 'cart' });

    my %params = (
        cmd           => '_cart',
        upload        => 1,
        business      => $self->vendorId,
        currency_code => $self->currency,
        no_shipping   => 1,

        return        => $return->as_string,
        cancel_return => $cancel->as_string,
        lc            => $i18n->getLanguage->{locale},

        #handling_cart        => $cart->calculateShipping,  ##According to https://www.x.com/message/180018#180018
        tax_cart             => $cart->calculateTaxes,
        discount_amount_cart => abs($cart->calculateShopCreditDeduction),

        # When we verify that we have a valid transaction ID later on in
        # processPayment, we'll make sure it's the cart we think it is.
        custom => $cart->getId,
    );
    
    my $counter = 0;
    foreach my $item (@{ $cart->getItems}) {
        ++$counter;
        $params{"amount_$counter"}      = $item->getSku->getPrice;
        $params{"quantity_$counter"}    = $item->get('quantity');
        $params{"item_name_$counter"}   = $item->get('configuredTitle');
        $params{"item_number_$counter"} = $item->get('itemId');
    }
    if ($cart->requiresShipping) {
        ++$counter;
        $params{"amount_$counter"}      = $cart->calculateShipping;
        $params{"quantity_$counter"}    = 1;
        $params{"item_name_$counter"}   = $i18n->get('shipping', 'Shop');
        $params{"item_number_$counter"} = 'Shipping';
    }

    return \%params;
}

#-------------------------------------------------------------------

=head2 payPalUrl

Returns the url of the paypal gateway, taking into account useSandbox.

=cut

sub payPalUrl {
    my $self  = shift;
    my $field = $self->useSandbox ? 'sandboxUrl' : 'liveUrl';
    return $self->$field;
}

#-------------------------------------------------------------------

=head2 processPayment ( transaction )

Implements the interface defined in WebGUI::Shop::PayDriver.  Notably, in case
of an error, the error is rendered as an html table of the params that paypal
passed to us.

=cut

sub processPayment {
    my ( $self ) = @_;

    my $success = $self->{_transactionSuccessful}   || 0;
    my $id      = $self->{_tx}                      || undef;
    my $status  = $self->{_statusCode}              || undef;
    my $message = $self->{_statusMessage}           || 'Waiting for checkout';

    return ( $success, $id, $status, $message );
}

#-------------------------------------------------------------------

=head2 _setPaymentStatus ( transactionSuccessful, ogoneId, statusCode, statusMessage )

Update the internal status of a payment, so that the next call to processPayment
returns the correct data.

=head3 transactionSuccessful

A boolean indicating whether or not the payment was successful.

=head3 tx

The PayPal issued transaction ID.

=head3 statusCode

The PayPal issued status code.

=head3 statusMessage

An updates status message

=cut

sub _setPaymentStatus {
    my ( $self ) = @_;

    $self->{_transactionSuccessful} = shift || 0;
    $self->{_tx}                    = shift || undef;
    $self->{_statusCode}            = shift || undef;
    $self->{_statusMessage}         = shift || undef;
}

#-------------------------------------------------------------------

=head2 www_completeTransaction 

Where paypal comes back to when a transaction has been completed.

=cut

sub www_completeTransaction {
    my $self    = shift;
    my $session = $self->session;

    my $params  = $self->getPayPalParams;
    if ($params->{PAYPAL_REQUEST_STATUS} =~ /FAIL/) {
        my $message = "<table><tr><th>Field</th><th>Value</th></tr>\n";
        foreach my $key ( keys %{ $params } ) {
            $message .= sprintf "<tr><td>%s</td><td>%s</td></tr>\n", $key, $params->{key};
        }
        $message .= "</table>\n";
        return ( 0, $params->{PAYPAL_TX}, $params->{PAYPAL_REQUEST_STATUS}, $message );
    }
    my $transaction = eval { WebGUI::Shop::Transaction->new($session, $params->{custom}); };
    if (my $e = Exception::Class->caught) {
        return $self->displayPaymentError();
    }
    $self->_setPaymentStatus(1, $params->{PAYPAL_TX}, $params->{payment_status}, 'Complete');
    $self->processTransaction($transaction);

    return $transaction->isSuccessful
        ? $transaction->thankYou
        : $self->displayPaymentError($transaction);
}


1;
