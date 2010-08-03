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

use base qw/WebGUI::Shop::PayDriver::PayPal/;

use URI;
use URI::Escape;
use LWP::UserAgent;
use Readonly;

Readonly my $I18N => 'PayDriver_PayPalStd'; 

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
sub definition {
    my $class   = shift;
    my $session = shift;
    WebGUI::Error::InvalidParam->throw( error => q{Must provide a session variable} )
        unless ref $session eq 'WebGUI::Session';
    my $definition = shift;

    my $i18n = WebGUI::International->new( $session, $I18N );

    tie my %fields, 'Tie::IxHash';
    %fields = (
        vendorId => {
            fieldType => 'text',
            label     => $i18n->get('vendorId'),
            hoverHelp => $i18n->get('vendorId help'),
        },
        signature => {
            fieldType => 'textarea',
            label     => $i18n->get('signature'),
            hoverHelp => $i18n->get('signature help'),
        },
        identityToken => {
            fieldType => 'text',
            label     => $i18n->get('identity token'),
            hoverHelp => $i18n->get('identity token help'),
        },
        currency => {
            fieldType    => 'selectBox',
            label        => $i18n->get('currency'),
            hoverHelp    => $i18n->get('currency help'),
            defaultValue => 'USD',
            options      => $class->getPaymentCurrencies(),
        },
        useSandbox => {
            fieldType    => 'yesNo',
            label        => $i18n->get('use sandbox'),
            hoverHelp    => $i18n->get('use sandbox help'),
            defaultValue => 1,
        },
        sandboxUrl => {
            fieldType    => 'text',
            label        => $i18n->get('sandbox url'),
            hoverHelp    => $i18n->get('sandbox url help'),
            defaultValue => 'https://www.sandbox.paypal.com/cgi-bin/webscr',
        },
        liveUrl => {
            fieldType    => 'text',
            label        => $i18n->get('live url'),
            hoverHelp    => $i18n->get('live url help'),
            defaultValue => 'https://www.paypal.com/cgi-bin/webscr',
        },
        buttonImage => {
            fieldType    => 'text',
            label        => $i18n->get('button image'),
            hoverHelp    => $i18n->get('button image help'),
            defaultValue => '',
        },
        summaryTemplateId  => {
            fieldType    => 'template',
            label        => $i18n->get('summary template'),
            hoverHelp    => $i18n->get('summary template help'),
            namespace    => 'Shop/Credentials',
            defaultValue => '',
        },
    );

    push @{$definition},
        {
        name       => $i18n->get('PayPal'),
        properties => \%fields,
        };

    return $class->SUPER::definition( $session, $definition );
}

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
    my $v      = $self->paymentVariables;
    my $fields = join "\n", map {
        WebGUI::Form::hidden( $session, { name => $_, value => $v->{$_} } )
    } (keys %$v);

    # Customized buttons are allowed; If they didn't give us one, we'll just
    # do a submit button with i18n'd paypal text.  If they did, we'll use an
    # image submit.
    my $button;
    my $i18n = WebGUI::International->new( $session, 'PayDriver_PayPalStd' );
    my $text = $i18n->get('PayPal');
    if ( $self->get('buttonImage') ) {
        my $raw = $self->get('buttonImage');
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

=head2 paymentVariables

Returns a hashref of the payment variables to be used as hidden form fields
when clicking the getButton button.

=cut

sub paymentVariables {
    my $self = shift;
    my $url  = $self->session->url;
    my $base = $url->getSiteURL . $url->page;
    my $cart = $self->getCart;

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
        business      => $self->get('vendorId'),
        currency_code => $self->get('currency'),
        no_shipping   => 1,

        return        => $return->as_string,
        cancel_return => $cancel->as_string,

        handling_cart        => $cart->calculateShipping,  ##According to https://www.x.com/message/180018#180018
        tax_cart             => $cart->calculateTaxes,
        discount_amount_cart => -($cart->calculateShopCreditDeduction),

        # When we verify that we have a valid transaction ID later on in
        # processPayment, we'll make sure it's the cart we think it is.
        custom => $cart->getId,
    );
    
    my $counter = 0;
    foreach my $item (@{ $cart->getItems}) {
        my $n = ++$counter;
        $params{"amount_$n"}      = $item->getSku->getPrice;
        $params{"quantity_$n"}    = $item->get('quantity');
        $params{"item_name_$n"}   = $item->get('configuredTitle');
        $params{"item_number_$n"} = $item->get('itemId');
    }

    return \%params;
}

#-------------------------------------------------------------------

=head2 payPalUrl

Returns the url of the paypal gateway, taking into account useSandbox.

=cut

sub payPalUrl {
    my $self  = shift;
    my $field = $self->get('useSandbox') ? 'sandboxUrl' : 'liveUrl';
    return $self->get($field);
}

#-------------------------------------------------------------------

=head2 processPayment ( transaction )

Implements the interface defined in WebGUI::Shop::PayDriver.  Notably, in case
of an error, the error is rendered as an html table of the params that paypal
passed to us.

=cut

sub processPayment {
    my ( $self, $transaction ) = @_;
    my $session = $self->session;

    # To prevent a spoofed post to this url, we'll get the info from paypal
    # instead of relying on what was passed to us.
    my $tx = $session->form->process('tx');

    my %form = (
        cmd => '_notify-synch',
        tx  => $tx,
        at  => $self->get('identityToken'),
    );
    my $response = LWP::UserAgent->new->post($self->payPalUrl, \%form);
    my ($status, @lines) = split("\n", uri_unescape($response->content));
    my %params = map { split /=/ } @lines;

    if ($status =~ /FAIL/) {
        my $message = '<table><tr><th>Field</th><th>Value</th></tr>';
        foreach my $key ( keys %params ) {
            $message .= "<tr><td>$key</td><td>$params{$key}</td></tr>";
        }
        $message .= '</table>';
        return ( 0, $tx, $status, $message );
    }

    # Make sure the transaction is for this cart to prevent spoofing
    my $cartId = $self->getCart->getId;
    if ($params{custom} ne $cartId) {
        my $user = $session->user;
        my $name = $user->username;
        my $id   = $user->userId;
        $session->log->warn("SECURITY WARNING: $name (id: $id) tried to " .
            "checkout cart $cartId with PayPal transaction $tx, which " .
            "did not match the cart we passed ($params{custom})");

        my $i18n = WebGUI::International->new( $session, $I18N );
        return ( 0, $tx, 'FAIL', $i18n->get('cart transaction mismatch') );
    }

    $status = $params{payment_status};
    return ( 1, $tx, $status, $status, $status );
} ## end sub processPayment

#-------------------------------------------------------------------

=head2 www_completeTransaction 

Where paypal comes back to when a transaction has been completed.

=cut

sub www_completeTransaction {
    my $self = shift;

    my $transaction = $self->processTransaction;

    return $transaction->get('isSuccessful')
        ? $transaction->thankYou
        : $self->displayPaymentError($transaction);
}


1;
