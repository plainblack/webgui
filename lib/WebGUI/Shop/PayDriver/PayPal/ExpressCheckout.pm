package WebGUI::Shop::PayDriver::PayPal::ExpressCheckout;

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
use base qw/WebGUI::Shop::PayDriver/;

use LWP::UserAgent;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Form;
use URI::Escape;
use URI::Split;
use URI;
use Readonly;
use Data::Dumper;

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

Readonly my $I18N => 'PayDriver_ExpressCheckout';

#-------------------------------------------------------------------

=head2 apiUrl

Returns the URL for the PayPal API (or the sandbox, if we are configured to
use the sandbox)

=cut

sub apiUrl {
    my $self = shift;
    return $self->get( $self->get('testMode') ? 'apiSandbox' : 'api' );
}

#-------------------------------------------------------------------

=head2 definition

Standard definition method.

=cut

sub definition {
    my ( $class, $session, $definition ) = @_;
    my $i18n = WebGUI::International->new( $session, $I18N );

    tie my %fields, 'Tie::IxHash';
    my @fieldNames = qw(
        paypal   sandbox
        api      apiSandbox
        user     password
        currency testMode
        signature
    );

    foreach my $f (@fieldNames) {
        $fields{$f} = {
            fieldType => 'text',
            label     => $i18n->get($f),
            hoverHelp => $i18n->get("$f help"),
        };
    }

    $fields{currency}{defaultValue} = 'USD';

    $fields{testMode}{fieldType} = 'YesNo';

    $fields{sandbox}{defaultValue}    = 'https://www.sandbox.paypal.com/webscr';
    $fields{apiSandbox}{defaultValue} = 'https://api-3t.sandbox.payPal.com/nvp';

    $fields{paypal}{defaultValue} = 'https://www.paypal.com/webscr';
    $fields{api}{defaultValue}    = 'https://api-3t.payPal.com/nvp';

    $fields{summaryTemplateId}  = {
        fieldType    => 'template',
        label        => $i18n->get('summary template'),
        hoverHelp    => $i18n->get('summary template help'),
        namespace    => 'Shop/Credentials',
        defaultValue => 'GqnZPB0gLoZmqQzYFaq7bg',
    },

    push @{$definition}, {
        name       => $i18n->get('name'),
        properties => \%fields,
        };

    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

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
        . WebGUI::Form::submit( $session, { value => $self->get('name') } )
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
    $args->{USER}      = $self->get('user');
    $args->{PWD}       = $self->get('password');
    $args->{SIGNATURE} = $self->get('signature');

    return $args;
}

#-------------------------------------------------------------------

=head2 payPalUrl

Returns the URL for the PayPal site (or the sandbox, if we are configured to
use the sandbox)

=cut

sub payPalUrl {
    my $self = shift;
    return $self->get( $self->get('testMode') ? 'sandbox' : 'paypal' );
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
        CURRENCYCODE  => $self->get('currency'),
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

    my $returnUrl = URI->new($base);
    $returnUrl->query_form( {
            shop             => 'pay',
            method           => 'do',
            do               => 'payPalCallback',
            paymentGatewayId => $self->getId,
        }
    );

    my $cancelUrl = URI->new($base);
    $cancelUrl->query_form( { shop => 'cart' } );

    my $form = $self->payPalForm(
        METHOD        => 'SetExpressCheckout',
        AMT           => $self->getCart->calculateTotal,
        CURRENCYCODE  => $self->get('currency'),
        RETURNURL     => $returnUrl->as_string,
        CANCELURL     => $cancelUrl->as_string,
        PAYMENTACTION => 'SALE',
    );

    my $testMode = $self->get('testMode');
    my $response = LWP::UserAgent->new->post( $self->apiUrl, $form );
    my $params   = $self->responseHash($response);
    my $i18n     = WebGUI::International->new( $self->session, $I18N );
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

    return $session->http->setRedirect($dest);
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

