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

=head2 getButton ( )

Return a form with button to finalize checkout from the Shop.

=cut

sub getButton {
    my ($self)    = @_;
    my $session = $self->session;

    # Generate 'Proceed' button
    my $i18n = WebGUI::International->new($session, 'PayDriver_Cash');
    return   WebGUI::Form::formHeader( $session )
           . $self->getDoFormTags('pay')
           . WebGUI::Form::submit( $session, { value => $i18n->get('Pay') } )
           . WebGUI::Form::formFooter( $session)
           ;
}

#-------------------------------------------------------------------

=head2 processPayment ( )

Returns (1, undef, 1, 'Success'), meaning that the payments whith this plugin always are successful.

=cut

sub processPayment {
    return (1, undef, 1, 'Success');
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
