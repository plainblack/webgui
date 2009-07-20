package WebGUI::Shop::PayDriver::PayPal::PayPalStd;

=head1 LEGAL
 -------------------------------------------------------------------
 PayPal Standard payment driver for WebGUI.
 Copyright (C) 2009  Invicta Services, LLC.
 -------------------------------------------------------------------
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along
 with this program; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 -------------------------------------------------------------------

=cut

use strict;
use warnings;

use base qw/WebGUI::Shop::PayDriver::PayPal/;

use URI;

=head1 NAME

PayPal Website payments standard

=head1 DESCRIPTION

A PayPal Website payments standard handler for WebGUI. Provides an interface to PayPal with cart contents
and transaction information on return.

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

    my $i18n = WebGUI::International->new( $session, 'PayDriver_PayPalStd' );

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
    my $i18n    = WebGUI::International->new( $session, 'PayDriver_PayPalStd' );
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

        rm            => 2,
        return        => $return->as_string,
        cancel_return => $cancel->as_string,

        shipping             => $cart->calculateShipping,
        tax_cart             => $cart->calculateTaxes,
        discount_amount_cart => -($cart->calculateShopCreditDeduction),
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
    my $params  = $session->form->paramsHashRef;
    my $status  = $params->{payment_status}; 
    my $tx      = $params->{txn_id};

    if ($status ne 'Completed') {
        my $message = '<table><tr><th>Field</th><th>Value</th></tr>';
        foreach my $key ( keys %$params ) {
            $message .= "<tr><td>$key</td><td>$params->{$key}</td></tr>";
        }
        $message .= '</table>';
        return ( 0, $tx, $status, $message );
    }

    return ( 1, $tx, $status, $status );
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

