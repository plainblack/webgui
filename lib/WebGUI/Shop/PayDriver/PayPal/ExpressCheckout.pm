package WebGUI::Shop::PayDriver::PayPal::ExpressCheckout;

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

use LWP::UserAgent;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Form;
use URI::Escape;
use URI::Split;
use URI;
use Readonly;
use Data::Dumper;

Readonly my $I18N => 'PayDriver_ExpressCheckout';
use Moose;
use WebGUI::Definition::Shop;
extends qw/WebGUI::Shop::PayDriver::PayPal/;

define pluginName => [qw/name PayDriver_ExpressCheckout/];

property paypal => (
        fieldType    => 'text',
        label        => ['paypal', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['paypal help', 'PayDriver_ExpressCheckout'],
        default      => 'https://www.paypal.com/webscr',
         );

property sandbox => (
        fieldType    => 'text',
        label        => ['sandbox', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['sandbox help', 'PayDriver_ExpressCheckout'],
        default      => 'https://www.sandbox.paypal.com/webscr',
         );

property api => (
        fieldType    => 'text',
        label        => ['api', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['api help', 'PayDriver_ExpressCheckout'],
        default      => 'https://api-3t.payPal.com/nvp',
         );

property apiSandbox => (
        fieldType    => 'text',
        label        => ['apiSandbox', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['apiSandbox help', 'PayDriver_ExpressCheckout'],
        default      => 'https://api-3t.sandbox.payPal.com/nvp',
         );

property user => (
        fieldType    => 'text',
        label        => ['user', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['user help', 'PayDriver_ExpressCheckout'],
         );

property password => (
        fieldType    => 'text',
        label        => ['password', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['password help', 'PayDriver_ExpressCheckout'],
         );

property currency => (
        fieldType    => 'text',
        label        => ['currency', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['currency help', 'PayDriver_ExpressCheckout'],
        default      => 'USD',
         );

property testMode => (
        fieldType    => 'yesNo',
        label        => ['testMode', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['testMode help', 'PayDriver_ExpressCheckout'],
         );

property signature => (
        fieldType    => 'text',
        label        => ['signature', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['signature help', 'PayDriver_ExpressCheckout'],
         );

property summaryTemplateId => (
        fieldType    => 'template',
        label        => ['summary template', 'PayDriver_ExpressCheckout'],
        hoverHelp    => ['summary template help', 'PayDriver_ExpressCheckout'],
        namespace    => 'Shop/Credentials',
        default      => 'GqnZPB0gLoZmqQzYFaq7bg',
         );

=head1 NAME

WebGUI::Shop::PayDriver::PayPal

=head1 DESCRIPTION 

Payment driver that talks to PayPal using the Express Checkout API

=head1 SYNOPSIS

# in webgui config file...

    "paymentDrivers" : [
        "WebGUI::Shop::PayDriver::Cash",
        "WebGUI::Shop::PayDriver::PayPal",
        ...
    ],

=head1 METHODS

The following methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 apiUrl

Returns the URL for the PayPal API (or the sandbox, if we are configured to
use the sandbox)

=cut

sub apiUrl {
    my $self = shift;
    return $self->get( $self->testMode ? 'apiSandbox' : 'api' );
}

#-------------------------------------------------------------------

=head2 getButton

Overridden, submits to www_sendToPaypal with the proper parameters.

=cut

sub getButton {
    my $self    = shift;
    my $session = $self->session;

    my $payForm
        = WebGUI::Form::formHeader($session)
        . $self->getDoFormTags('sendToPayPal')
        . WebGUI::Form::submit( $session, { value => $self->pluginName } )
        . WebGUI::Form::formFooter($session);

    return $payForm;
}

#-------------------------------------------------------------------

=head2 payPalForm ( %fields )

Returns a hashref representing a form (suitable for an LWP post) for talking
to the PayPal API.  Fields can be either name value pairs or a hashref.  If it
is a hashref, it will be modified in place.

=cut

sub payPalForm {
    my $self = shift;
    my $args = ref $_[0] eq 'HASH' ? shift : {@_};
    $args->{VERSION}   = '2.3';
    $args->{USER}      = $self->user;
    $args->{PWD}       = $self->password;
    $args->{SIGNATURE} = $self->signature;

    return $args;
}

#-------------------------------------------------------------------

=head2 payPalUrl

Returns the URL for the PayPal site (or the sandbox, if we are configured to
use the sandbox)

=cut

sub payPalUrl {
    my $self = shift;
    return $self->get( $self->testMode ? 'sandbox' : 'paypal' );
}

#-------------------------------------------------------------------

=head2 processPayment ( transaction )

Implements the interface defined in WebGUI::Shop::PayDriver.  Notably, on
error 'message' will be an HTML table representing the parameters that the
PayPal API spit back.

=cut

sub processPayment {
    my ( $self, $transaction ) = @_;

    my $form = $self->payPalForm(
        METHOD        => 'DoExpressCheckoutPayment',
        PAYERID       => $self->session->form->process('PayerId'),
        TOKEN         => $self->session->form->process('token'),
        AMT           => $self->getCart->calculateTotal,
        CURRENCYCODE  => $self->currency,
        PAYMENTACTION => 'SALE',
    );
    my $response = LWP::UserAgent->new->post( $self->apiUrl, $form );
    my $params = $self->responseHash($response);
    if ($params) {
        if ( $params->{ACK} !~ /^Success/ ) {
            my $status  = $params->{ACK};
            my $message = '<table><tr><th>Field</th><th>Value</th></tr>';
            foreach my $k ( keys %$params ) {
                $message .= "<tr><td>$k</td><td>$params->{$k}</td></tr>";
            }
            $message .= '</table>';
            return ( 0, undef, $status, $message );
        }

        my $status  = $params->{PAYMENTSTATUS};

        my $i18n    = WebGUI::International->new( $self->session, $I18N );
        my $message = sprintf $i18n->get('payment status'), $status;
        return ( 1, $params->{TRANSACTIONID}, $status, $message );
    }

    return ( 0, undef, $response->status_code, $response->status_line );
} ## end sub processPayment

#-------------------------------------------------------------------

=head2 responseHash (response)

Chops up the body of a paypal response into a hashref (or undef if the request
failed)

=cut

sub responseHash {
    my ( $self, $response ) = @_;
    return undef unless $response->is_success;
    local $_ = uri_unescape( $response->content );
    return { map { split /=/ } split /[&;]/ };
}

#-------------------------------------------------------------------

=head2 www_payPalCallback

Handler that PayPal redirects to once payment has been confirmed on their end

=cut

sub www_payPalCallback {
    my $self = shift;

    my $transaction = $self->processTransaction;

    return $transaction->get('isSuccessful')
        ? $transaction->thankYou
        : $self->displayPaymentError($transaction);
}

#-------------------------------------------------------------------

=head2 www_sendToPayPal

Sets up payPal transaction and redirects the user off to payPal land

=cut

sub www_sendToPayPal {
    my $self    = shift;
    my $session = $self->session;
    my $url     = $session->url;
    my $base    = $url->getSiteURL . $url->page;

    my $i18n    = WebGUI::International->new( $self->session, $I18N );
    my $returnUrl = URI->new($base);
    $returnUrl->query_form( {
            shop             => 'pay',
            method           => 'do',
            do               => 'payPalCallback',
            paymentGatewayId => $self->getId,
            LOCALECODE       => $i18n->getLanguage->{locale},
        }
    );

    my $cancelUrl = URI->new($base);
    $cancelUrl->query_form( { shop => 'cart' } );

    my $form = $self->payPalForm(
        METHOD        => 'SetExpressCheckout',
        AMT           => $self->getCart->calculateTotal,
        CURRENCYCODE  => $self->currency,
        RETURNURL     => $returnUrl->as_string,
        CANCELURL     => $cancelUrl->as_string,
        PAYMENTACTION => 'SALE',
    );

    my $testMode = $self->testMode;
    my $response = LWP::UserAgent->new->post( $self->apiUrl, $form );
    my $params   = $self->responseHash($response);
    my $error;

    if ($params) {
        unless ( $params->{ACK} =~ /^Success/ ) {
            my $log = sprintf "Paypal error: Request/response below: %s\n%s\n", Dumper($form), Dumper($params);
            $log .= $response->request->as_string;
            $session->log->error($log);
            $error = $i18n->get('internal paypal error');
        }
    }
    else {
        $error = $response->status_line;
    }

    if ($error) {
        my $message = sprintf $i18n->get('api error'), $error;
        return $session->style->userStyle($message);
    }

    my $dest = URI->new( $self->payPalUrl );
    $dest->query_form( {
            cmd   => '_express-checkout',
            token => $params->{TOKEN},
        }
    );

    return $session->response->setRedirect($dest);
} ## end sub www_sendToPayPal

=head1 LIMITATIONS

=over 4 

=item 

Doesn't handle recurring payments, although Paypal can do that.

=item

There is no itemization of the cart for Paypal's records, just one total
(could do taxes, shipping, each item as separate things).

=item 

Paypal's shipping information is ignored; this could be changed to accept new
shipping info from PayPal, but that's somewhat fragile.  We're currently just
pretending PayPal is a payment gateway.

=back

=cut

1;

