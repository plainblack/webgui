package WebGUI::Shop::PayDriver::CreditCard::AuthorizeNet;

use strict;

use base qw/WebGUI::Shop::PayDriver::CreditCard/;

use DateTime;
use Readonly;
use Business::OnlinePayment;

Readonly my $I18N => 'PayDriver_AuthorizeNet';

=head1 NAME

WebGUI::Shop::PayDriver::CreditCard::AuthorizeNet

=head1 DESCRIPTION 

Payment driver that uses Business::OnlinePayment to process transactions
through Authorize.net

=head1 SYNOPSIS

    # in webgui config file...

    "paymentDrivers" : [
        "WebGUI::Shop::PayDriver::Cash",
        "WebGUI::Shop::PayDriver::CreditCard::AuthorizeNet",
        ...
    ],

=head1 METHODS

The following methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 appendCredentialVars ( var )

Overridden to add the card type field

=cut

sub appendCredentialVars {
    my ( $self, $var ) = @_;
    my $session = $self->session;
    my $i18n = WebGUI::International->new( $session, $I18N );
    $self->SUPER::appendCredentialVars($var);

    $var->{cardTypeField} = WebGUI::Form::selectBox(
            $session, {
                name    => 'cardType',
                options => { map { $_ => $_ } ( 'Visa', 'MasterCard', 'American Express', 'Discover', ) },
            }
        );

    return;
} ## end sub appendCredentialVars

#-------------------------------------------------------------------

=head2 cancelRecurringPayment ( transaction )

Cancels a recurring transaction. Returns an array containing ( isSuccess, gatewayStatus, gatewayError).

=head3 transaction

The instanciated recurring transaction object.

=cut

sub cancelRecurringPayment {
    my ( $self, $transaction ) = @_;
    my $session = $self->session;

    my $tx = $self->gatewayObject;
    $tx->content(
        subscription => $transaction->get('transactionCode'),
        login        => $self->get('login'),
        password     => $self->get('transaction_key'),
        action       => 'Cancel Recurring Authorization',
    );
    $tx->submit;

    return $self->gatewayResponse($tx);
}

#-------------------------------------------------------------------
sub definition {
    my ( $class, $session, $definition ) = @_;

    my $i18n = WebGUI::International->new( $session, $I18N );

    tie my %fields, 'Tie::IxHash', (
        login => {
            fieldType => 'text',
            label     => $i18n->get('login'),
            hoverHelp => $i18n->get('login help'),
        },
        transaction_key => {
            fieldType => 'text',
            label     => $i18n->get('transaction key'),
            hoverHelp => $i18n->get('transaction key help'),
        },
        testMode => {
            fieldType => 'YesNo',
            label     => $i18n->get('test mode'),
            hoverHelp => $i18n->get('test mode help'),
        },
        );

    push @{$definition}, {
        name       => $i18n->get('name'),
        properties => \%fields,
        };

    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 gatewayObject ( params )

Returns a Business::OnlinePayment object, possibly with options set from the
paydriver properties.  params can be a hashref of the options that would
normally be passed to tx->content, in which case these will be passed along.

=cut

sub gatewayObject {
    my ( $self, $params ) = @_;

    my $tx = Business::OnlinePayment->new('AuthorizeNet');
    if ( $self->get('testMode') ) {

        # Yes, we need to do both these things.  The BOP interfaces tend to
        # ony honor one or the other of them.
        $tx->test_transaction(1);
        $tx->server('test.authorize.net');
    }
    $tx->content(%$params) if $params;

    return $tx;
}

#-------------------------------------------------------------------

=head2 gatewayResponse ( tx )

Returns the various responses required by the PayDriver interface from the
passed Business::OnlinePayment object.

=cut

sub gatewayResponse {
    my ( $self, $tx ) = @_;
    return ( $tx->is_success, $tx->order_number, $tx->result_code, $tx->error_message );
}

#-------------------------------------------------------------------

sub handlesRecurring {1}

#-------------------------------------------------------------------

=head2 paymentParams

Returns a hashref of the billing address and card information, translated into
a form that Business::OnlinePayment likes

=cut

sub paymentParams {
    my $self = shift;
    my $card = $self->{_cardData};
    my $bill = $self->getCart->getBillingAddress->get();

    my %params = (
        type            => $card->{type},
        login           => $self->get('login'),
        transaction_key => $self->get('transaction_key'),
        first_name      => $bill->{firstName},
        last_name       => $bill->{lastName},
        address         => $bill->{address1},
        city            => $bill->{city},
        state           => $bill->{state},
        zip             => $bill->{code},
        card_number     => $card->{acct},
        expiration      => sprintf '%2d/%2d',
        @{$card}{ 'expMonth', 'expYear' },
    );
    $params{cvv2} = $card->{cvv2} if $self->get('useCVV2');
    return \%params;
} ## end sub paymentParams

#-------------------------------------------------------------------

sub processCredentials {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new( $session, $I18N );
    my $error   = $self->SUPER::processCredentials;

    my $type = $session->form->process('cardType');

    unless ($type) {
        $error ||= [];
        push @$error, $i18n->get('invalid cardType');
    }

    return $error if defined $error;

    $self->{_cardData}->{type} = $type;

    return;
} ## end sub processCredentials

#-------------------------------------------------------------------

sub processPayment {
    my ( $self, $transaction ) = @_;
    my $params = $self->paymentParams;

    if ( $transaction->isRecurring ) {
        my $items = $transaction->getItems;
        if ( @$items > 1 ) {
            WebGUI::Error::InvalidParam->throw(
                error => 'This payment gateway can only handle one recurring item at a time' );
        }

        my $item = $items->[0];
        my $sku  = $item->getSku;

        my %translateInterval = (
            Weekly     => '7 days',
            BiWeekly   => '14 days',
            FourWeekly => '28 days',
            Monthly    => '1 month',
            Quarterly  => '3 months',
            HalfYearly => '6 months',
            Yearly     => '12 months',
        );

        # BOP::AuthorizeNet::ARB has an API that's inconsistant with the AIM
        # api -- it wants password instead of transaction_key.  Go figure.
        $params->{password} = delete $params->{transaction_key};

        $params->{action}      = 'Recurring Authorization';
        $params->{interval}    = $translateInterval{ $sku->getRecurInterval };
        $params->{start}       = DateTime->today->ymd;
        $params->{periods}     = '9999';                                         # magic value that means 'never stop'
        $params->{description} = $item->get('configuredTitle');
    } ## end if ( $transaction->isRecurring)
    else {
        $params->{action} = 'Normal Authorization';
    }

    $params->{amount} = $transaction->get('amount');
    my $tx = $self->gatewayObject($params);
    $tx->submit;
    return $self->gatewayResponse($tx);
} ## end sub processPayment

1;

