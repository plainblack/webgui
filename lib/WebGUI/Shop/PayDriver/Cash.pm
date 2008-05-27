package WebGUI::Shop::PayDriver::Cash;

use strict;

use WebGUI::Shop::PayDriver;
use WebGUI::Exception;

use base qw/WebGUI::Shop::PayDriver/;

#-------------------------------------------------------------------
sub canCheckoutCart {
    my $self    = shift;
    my $cart    = $self->getCart;

    return 0 unless $cart->readyForCheckout;
    return 0 if $cart->requiresRecurringPayment;

    return 1;
}

#-------------------------------------------------------------------

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;

    my $i18n = WebGUI::International->new($session, 'PayDriver_Cash');

    tie my %fields, 'Tie::IxHash';

    push @{ $definition }, {
        name        => $i18n->echo('Cash'),
        properties  => \%fields,
    };

    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub getAddress {
    my ($self, $addressId)    = @_;
    if ($addressId) {
        return $self->getCart->getAddressBook->getAddress( $addressId );
    }
    # No billing address selected yet so return undef.
    return undef;
}

#-------------------------------------------------------------------

sub getButton {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'PayDriver_Cash');

    my $payForm = WebGUI::Form::formHeader($session)
        . $self->getDoFormTags('getCredentials')
        . WebGUI::Form::submit($session, {value => $i18n->echo('Cash') })
        . WebGUI::Form::formFooter($session);

    return $payForm;
}


#-------------------------------------------------------------------

sub processPayment {
    return (1, undef, 1, 'Success');
}

#-------------------------------------------------------------------

sub www_displayStatus {

}

#-------------------------------------------------------------------
sub www_getCredentials {
    my ($self, $addressId)    = @_;
    my $session = $self->session;
    $addressId = $session->form->process('addressId') if ($addressId eq "");
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

    # Get billing address
    my $billingAddress = eval { $self->getAddress($addressId) };
   
    my $billingAddressHtml;
    if ($billingAddress) {
        $billingAddressHtml = $billingAddress->getHtmlFormatted;
    }

    # Generate 'Proceed' button
    my $proceedButton = WebGUI::Form::formHeader( $session )
        . $self->getDoFormTags('pay')
        . WebGUI::Form::hidden($session, {name=>"addressId", value=>$addressId})
        . WebGUI::Form::submit( $session, { value => 'Pay' } )
        . WebGUI::Form::formFooter( $session);

    return $session->style->userStyle($addressButton.'<br />'.$billingAddressHtml.'<br />'.$proceedButton);
}

#-------------------------------------------------------------------

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

sub www_setBillingAddress {
    my $self    = shift;
    my $session = $self->session;
    return $self->www_getCredentials($session->form->process('addressId'));
}

1;

