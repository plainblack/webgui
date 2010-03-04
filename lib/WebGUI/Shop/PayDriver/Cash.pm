package WebGUI::Shop::PayDriver::Cash;

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
use Tie::IxHash;

use base qw/WebGUI::Shop::PayDriver/;

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

    my $i18n = WebGUI::International->new($session, 'PayDriver_Cash');

    tie my %fields, 'Tie::IxHash';

    push @{ $definition }, {
        name        => $i18n->get('label'),
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

    my $payForm = WebGUI::Form::formHeader($session)
        . $self->getDoFormTags('getCredentials')
        . WebGUI::Form::submit($session, {value => $self->get('label') })
        . WebGUI::Form::formFooter($session);

    return $payForm;
}

#-------------------------------------------------------------------

=head2 processPayment ( )

Returns (1, undef, 1, 'Success'), meaning that the payments whith this plugin always are successful.

=cut

sub processPayment {
    return (1, undef, 1, 'Success');
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

    # Generate the json string that defines where the address book posts the selected address
    my $callbackParams = {
        url     => $session->url->page,
        params  => [
            { name => 'shop',               value => 'pay' },
            { name => 'method',             value => 'do' },
            { name => 'do',                 value => 'setBillingAddress' },
            { name => 'paymentGatewayId',   value => $self->getId },
        ],
    };
    my $callbackJson = JSON::to_json( $callbackParams );

    # Generate 'Choose billing address' button
    my $addressButton = WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { name => 'shop',     value => 'address' } )
        . WebGUI::Form::hidden( $session, { name => 'method',   value => 'view' } )
        . WebGUI::Form::hidden( $session, { name => 'callback', value => $callbackJson } )
        . WebGUI::Form::submit( $session, { value => 'Choose billing address' } )
        . WebGUI::Form::formFooter( $session);


    # Generate 'Proceed' button
    my $proceedButton = WebGUI::Form::formHeader( $session )
        . $self->getDoFormTags('pay')
        . WebGUI::Form::hidden($session, {name=>"addressId", value=>$address->getId})
        . WebGUI::Form::submit( $session, { value => 'Pay' } )
        . WebGUI::Form::formFooter( $session);

    return $session->style->userStyle($addressButton.'<br />'.$billingAddressHtml.'<br />'.$proceedButton);
}

#-------------------------------------------------------------------

=head2 www_pay ( )

Checks credentials, and completes the transaction if those are correct.

=cut

sub www_pay {
    my $self    = shift;
    my $session = $self->session;
    my $cart    = $self->getCart;
    my $i18n    = WebGUI::International->new($session, 'PayDriver_Cash');
    my $var;

    # Make sure we can checkout the cart
    return "" unless $self->canCheckoutCart;

    # Make sure all required credentials have been supplied
    my $billingAddress = $self->getAddress( $session->form->process('addressId') );
    return $self->www_getCredentials unless $billingAddress;

    # Complete the transaction
    my $transaction = $self->processTransaction( $billingAddress );
    return $transaction->thankYou();
}

#-------------------------------------------------------------------

=head2 www_setBillingAddress {

Stores the selected billing address in this instance.

=cut

sub www_setBillingAddress {
    my $self    = shift;
    my $session = $self->session;
    return $self->www_getCredentials($session->form->process('addressId'));
}

1;

