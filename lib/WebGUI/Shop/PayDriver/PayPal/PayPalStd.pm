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
use LWP::UserAgent;
use Crypt::SSLeay;

use base qw/WebGUI::Shop::PayDriver::PayPal/;

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

sub handlesRecurring {
    return 0;
}

#-------------------------------------------------------------------

=head2 canCheckoutCart ( )

Returns whether the cart can be checked out by this plugin.

=cut

sub canCheckoutCart {
    my $self = shift;
    my $cart = $self->getCart;

    return 0 unless $cart->readyForCheckout;
    return 0 if $cart->requiresRecurringPayment;

    return 1;
}

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
        buttonImage => {
            fieldType    => 'text',
            label        => $i18n->get('button image'),
            hoverHelp    => $i18n->get('button image help'),
            defaultValue => '',
        },
        emailMessage => {
            fieldType => 'textarea',
            label     => $i18n->get('emailMessage'),
            hoverHelp => $i18n->get('emailMessage help'),
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
    my $i18n    = WebGUI::International->new( $session, 'PayDriver_PayPalStd' );

    my $payForm = WebGUI::Form::formHeader($session) . $self->getDoFormTags('pay');

    if ( $self->get('buttonImage') ) {
        my $button = $self->get('buttonImage');
        WebGUI::Macro::process( $session, \$button );
        $payForm
            .= '<input type="image" src="' 
            . $button
            . '" border="0" name="submit" alt="'
            . $i18n->get('PayPal') . '"> ';
    }
    else {
        $payForm .= WebGUI::Form::submit( $session, { value => $i18n->get('PayPal') } );
    }

    $payForm .= WebGUI::Form::formFooter($session);

    return $payForm;
}

#-------------------------------------------------------------------

=head2 processTransaction ( [ paymentAddress ] )

This method is responsible for handling success or failure from the payment processor, completing or denying the transaction, and sending out notification and receipt emails. Returns a WebGUI::Shop::Transaction object.
This method is overridden from the parent class to allow asynchronous completion / denial of PayPal payments.

=head3 paymentAddress

A reference to a WebGUI::Shop::Address object that should be attached as payment information. Not required.

=cut

sub processTransaction {
    my ( $self, $paymentAddress ) = @_;

    my $cart = $self->getCart;

    # Setup tranasction properties
    my $transactionProperties;
    $transactionProperties->{paymentMethod}  = $self;
    $transactionProperties->{cart}           = $cart;
    $transactionProperties->{paymentAddress} = $paymentAddress if defined $paymentAddress;
    $transactionProperties->{isRecurring}    = $cart->requiresRecurringPayment;

    # Create a transaction...
    my $transaction = WebGUI::Shop::Transaction->create( $self->session, $transactionProperties );

    # And handle the payment for it
    my $session = $self->session;
    my $config  = $session->config;

    my $f = WebGUI::HTMLForm->new(
        $session,
        action => ( $self->get('useSandbox') ? $self->getPayPalSandboxUrl() : $self->getPayPalUrl() ),
        extras => 'name="paypal_form"'
    );

    $f->hidden( name => 'business',  value => $self->get('vendorId') );
    $f->hidden( name => 'cmd',       value => '_cart' );
    $f->hidden( name => 'site_url',  value => $session->setting->get("companyURL") );
    $f->hidden( name => 'image_url', value => '' );
    $f->hidden(
        name => 'return',
        value =>
            $session->url->page( "shop=pay;method=do;do=completeTransaction;paymentGatewayId=" . $self->getId, 1 )
    );    ## PayPal says OK for now
    $f->hidden(
        name => 'cancel_return',
        value =>
            $session->url->page( "shop=pay;method=do;do=cancelTransaction;paymentGatewayId=" . $self->getId, 1 )
    );    ## Error / user cancel

# $f->hidden(name=>'notify_url', value=>$session->url->page("shop=pay;method=do;do=IPNnotifyTransaction;paymentGatewayId=".$self->getId, 1));
    $f->hidden( name => 'notify_url', value => '' );     ##no IPN for now, get OK from PDT auto-return
    $f->hidden( name => 'rm',         value => '2' );    ## use POST
    $f->hidden( name => 'currency_code', value => $self->get('currency') );
    $f->hidden( name => 'lc',            value => 'US' );
    $f->hidden( name => 'bn',            value => 'toolkit-perl' );
    $f->hidden( name => 'cbt',           value => 'Continue >>' );

    # <!-- Payment Page Information -->
    $f->hidden( name => 'no_shipping', value => '1' );          # do not display shipping addr
    $f->hidden( name => 'no_note',     value => '0' );
    $f->hidden( name => 'cn',          value => 'Comments' );
    $f->hidden( name => 'cs',          value => '' );

    # <!-- Cart Information -->
    # does not get used for uploaded carts
    $f->hidden( name => 'item_name', value => 'WebGUI cart' );
    $f->hidden(
        name  => 'amount',
        value => $transaction->get('amount') - $transaction->get('taxes') - $transaction->get('shippingPrice')
    );

    # <!-- Product Information for each item in our cart -->
    $f->hidden( name => 'upload', value => '1' );
    my $itemList = $transaction->getItems;
    my $itemNum  = 0;
    foreach my $item ( @{$itemList} ) {

        # items numbered 1++
        $itemNum++;

        # glue item number to WebGUI itemId
        $f->hidden( name => 'item_number_' . $itemNum, value => $item->get('itemId') );
        $f->hidden( name => 'item_name_' . $itemNum,   value => $item->get('configuredTitle') );
        $f->hidden( name => 'quantity_' . $itemNum,    value => $item->get('quantity') );
        $f->hidden( name => 'amount_' . $itemNum,      value => $item->get('price') );
    }

    # <!-- Shipping and Misc Information -->
    $f->hidden( name => 'shipping',      value => $transaction->get('shippingPrice') );
    $f->hidden( name => 'shipping2',     value => '' );                                   # no individual shipping
    $f->hidden( name => 'handling_cart', value => '0.00' );                               # no separate handling
    $f->hidden( name => 'tax_cart',      value => $transaction->get('taxes') );           # no separate taxes
    $f->hidden( name => 'custom',        value => '' );
    $f->hidden( name => 'invoice',       value => $transaction->getId )
        ;    # need to identify OUR TX so we can update it later

    # <!-- Customer Information -->
    $f->hidden( name => 'address_override', value => 1 );

    $f->hidden(
        name  => 'first_name',
        value => substr(
            $transaction->get('shippingAddressName'), 0,
            rindex( $transaction->get('shippingAddressName'), ' ' )
        )
    );
    $f->hidden(
        name  => 'last_name',
        value => substr(
            $transaction->get('shippingAddressName'),
            rindex( $transaction->get('shippingAddressName'), ' ' ) + 1
        )
    );

    $f->hidden( name => 'address1', value => $transaction->get('shippingAddress1') );
    $f->hidden( name => 'address2', value => $transaction->get('shippingAddress2') );
    $f->hidden( name => 'city',     value => $transaction->get('shippingCity') );
    $f->hidden( name => 'state',    value => $transaction->get('shippingState') );
    $f->hidden( name => 'zip',      value => $transaction->get('shippingCode') );
    $f->hidden( name => 'country',  value => $self->getPaypalCountry( $transaction->get('shippingCountry') ) );

    if ( $session->user->profileField('email') ) {
        $f->hidden( name => 'email', value => $session->user->profileField('email') );
    }
    $f->hidden( name => 'night_phone_a', value => $transaction->get('shippingPhoneNumber') );
    $f->hidden( name => 'night_phone_b', value => '' );
    $f->hidden( name => 'night_phone_c', value => '' );

    return
          $f->print
        . '<center><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Processing Transaction . . . </font></center>'
        . '<script>document.paypal_form.submit();</script>';

}

#-------------------------------------------------------------------

=head2 www_cancelTransaction 

Cancels the transaction defined by the C<invoice> form variable.

=cut

sub www_cancelTransaction {
    my $self    = shift;
    my $session = $self->session;

    my %pdt;
    my $retstr = '';
    foreach my $input_name ( $self->session->request->param ) {
        $pdt{$input_name} = $self->session->request->param($input_name);
        $retstr .= $input_name . ":" . $self->session->request->param($input_name) . "<br />";
    }

    my $transaction = eval { WebGUI::Shop::Transaction->newByGatewayId( $session, $pdt{invoice}, $self->getId ) };

    # First check whether the original transaction actualy exists
    if ( WebGUI::Error->caught || !( defined $transaction ) ) {
        $session->errorHandler->warn("PayPal Standard: No transaction ID: $pdt{invoice}");
        return;
    }
    $transaction->denyPurchase( $pdt{invoice}, 0, $pdt{payment_status} );
    return $self->displayPaymentError($transaction);
}

#-------------------------------------------------------------------

=head2 www_completeTransaction 

Finishes the transaction for this driver.

=cut

sub www_completeTransaction {
    my $self    = shift;
    my $session = $self->session;

    my $paypal_url;

    my %paypal;    ## return variables from PDT

## find TX key from PayPal PDT
    my $tx = $self->session->form->get("tx");

    if ($tx) {

        # found a tx, re-present it for all the TX details
        $paypal_url = $self->get('useSandbox') ? $self->getPayPalSandboxUrl() : $self->getPayPalUrl();

        my $query      = join( "&", "cmd=_notify-synch", "tx=" . $tx, "at=" . $self->get('signature') );
        my $user_agent = new LWP::UserAgent;
        my $request    = new HTTP::Request( "POST", $paypal_url );

        $request->content_type("application/x-www-form-urlencoded");
        $request->content($query);

        # Make the request
        my $result = $user_agent->request($request);

        if ( $result->is_error ) {
            $session->errorHandler->warn("PayPal Standard: PayPal server seems offline.");
            return;
        }

        # Decode the response into individual lines and unescape any HTML escapes
        my @response = split( "\n", $self->session->url->unescape( $result->content ) );

        # The status is always the first line of the response.
        my $status = shift @response;

        foreach my $response_line (@response) {
            my ( $key, $value ) = split "=", $response_line;
            $paypal{$key} = $value;
        }

        my $transaction = eval { WebGUI::Shop::Transaction->new( $session, $paypal{invoice} ) };

        # First check whether the original transaction actualy exists
        if ( WebGUI::Error->caught || !( defined $transaction ) ) {
            $session->errorHandler->warn(
                "PayPal Standard: No WebGUI transaction ID: $paypal{invoice}," . $self->getId );
            return;
        }

        if ( $status eq "SUCCESS" ) {
            $transaction->completePurchase( $paypal{invoice}, 1, $paypal{payment_status} );
            my $cart = $self->getCart;
            $cart->onCompletePurchase;
            $self->sendNotifications($transaction);
        }
        elsif ( $status eq "FAIL" ) {
            $transaction->denyPurchase( $paypal{invoice}, 0, $paypal{payment_status} );
        }

        if ( $transaction->get('isSuccessful') ) {
            return $transaction->thankYou();
        }
        else {
            return $self->displayPaymentError($transaction);
        }
    }
    else {    ## no tx from paypal
        $session->errorHandler->warn("PayPal Standard: No transaction ID");
    }
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Generates an edit form.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    my $admin   = WebGUI::Shop::Admin->new($session);
    my $i18n    = WebGUI::International->new( $session, 'PayDriver_PayPalStd' );

    return $session->privilege->insufficient() unless $admin->canManage;

    my $form = $self->getEditForm;

    $form->submit;

    # adds instructions for IPN etc.
    my $output = '<br />';
    $output
        .= $i18n->get('extra info')
        . '<br /><br />'
        . '<b>https://'
        . $session->config->get("sitename")->[0]
        . '/?shop=pay;method=do;do=completeTransaction;paymentGatewayId='
        . $self->getId . '</b>';

    return $admin->getAdminConsole->render( $form->print . $output, $i18n->get( 'payment methods', 'PayDriver' ) );
}

#-------------------------------------------------------------------

=head2 www_pay 

Web facing wrapper method for C<processTransaction>.

=cut

sub www_pay {
    my $self    = shift;
    my $session = $self->session;

    # Payment time!
    return $self->processTransaction();
}

1;

