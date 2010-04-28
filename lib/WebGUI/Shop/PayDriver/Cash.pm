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
    %fields = (
        summaryTemplateId  => {
            fieldType    => 'template',
            label        => $i18n->get('summary template'),
            hoverHelp    => $i18n->get('summary template help'),
            namespace    => 'Shop/Credentials',
            defaultValue => '30h5rHxzE_Q0CyI3Gg7EJw',
        },
    );

    push @{ $definition }, {
        name        => $i18n->get('label'),
        properties  => \%fields,
    };

    return $class->SUPER::definition($session, $definition);
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

    # Generate 'Proceed' button
    my $i18n = WebGUI::International->new($session, 'PayDriver_Cash');
    my $var = {
        proceedButton => WebGUI::Form::formHeader( $session )
                       . $self->getDoFormTags('pay')
                       . WebGUI::Form::submit( $session, { value => $i18n->get('Pay') } )
                       . WebGUI::Form::formFooter( $session)
                       ,
    };
    $self->appendCartVariables($var);

    my $template = WebGUI::Asset::Template->new($session, $self->get("summaryTemplateId"));
    my $output;
    if (defined $template) {
        $template->prepare;
        $output = $template->process($var);
    }
    else {
        $output = $i18n->get('template gone', 'PayDriver_ITransact');
    }

    return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_pay ( )

Checks credentials, and completes the transaction if those are correct.

=cut

sub www_pay {
    my $self    = shift;
    my $var;

    # Make sure we can checkout the cart
    return "" unless $self->canCheckoutCart;

    # Complete the transaction
    my $transaction = $self->processTransaction( );
    return $transaction->thankYou();
}

1;
