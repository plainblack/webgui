package WebGUI::Shop::PayDriver::CreditCard;

use strict;
use Readonly;

=head1 NAME

WebGUI::Shop::PayDriver::CreditCard

=head2 DESCRIPTION

A base class for credit card payment drivers.  They all need pretty much the
same information, the only difference is the servers you talk to.  Leaves you
to handle recurring payments, processPayment, www_edit, and whatever else you
want to - but the user-facing code is pretty much taken care of.

=head2 METHODS

The following methods are available from this class.

=cut

use Moose;
use WebGUI::Definition::Shop;
extends 'WebGUI::Shop::PayDriver';

Readonly my $I18N => 'PayDriver_CreditCard';

define pluginName => 'Credit Card Base Class';
property useCVV2 => (
            fieldType   => 'yesNo',
            label       => ['use cvv2', $I18N],
            hoverHelp   => ['use cvv2 help', $I18N],
         );
property credentialsTemplateId => (
            fieldType    => 'template',
            label        => ['credentials template', $I18N],
            hoverHelp    => ['credentials template help', $I18N],
            namespace    => 'Shop/Credentials',
            default      => 'itransact_credentials1',
         );

#-------------------------------------------------------------------
sub _monthYear {
    my $session = shift;
    my $form    = $session->form;

	tie my %months, "Tie::IxHash";
	tie my %years,  "Tie::IxHash";
	%months = map { sprintf( '%02d', $_ ) => sprintf( '%02d', $_ ) } 1 .. 12;
	%years  = map { $_ => $_ } 2004 .. 2099;

    my $monthYear =
        WebGUI::Form::selectBox( $session, {
            name    => 'expMonth',
            options => \%months,
            value   => [ $form->process("expMonth") ]
        })
        . " / "
        . WebGUI::Form::selectBox( $session, {
            name    => 'expYear',
            options => \%years,
            value   => [ $form->process("expYear") ]
        });

    return $monthYear;
}

#-------------------------------------------------------------------

=head2 appendCredentialVars

Add template vars for www_getCredentials.  Override this to add extra fields.

=cut

sub appendCredentialVars {
    my ($self, $var) = @_;
    my $session = $self->session;
	my $u       = $session->user;
    my $form    = $session->form;
    my $i18n    = WebGUI::International->new($session, $I18N);

    $var->{formHeader} = WebGUI::Form::formHeader($session)
                       . $self->getDoFormTags('pay');

    $var->{formFooter} = WebGUI::Form::formFooter();

    my @fieldLoop;

    # Credit card information
    $var->{cardNumberField} = WebGUI::Form::text($session, {
        name  => 'cardNumber',
        value => $self->session->form->process("cardNumber"),
    });
    $var->{monthYearField} = WebGUI::Form::readOnly($session, {
        value => _monthYear( $session ),
    });
    $var->{cvv2Field} = WebGUI::Form::integer($session, {
        name  => 'cvv2',
        value => $self->session->form->process("cvv2"),
    }) if $self->get('useCVV2');

    $var->{checkoutButton} = WebGUI::Form::submit($session, {
        value => $i18n->get('checkout button', 'Shop'),
    });

    return;
}

#-------------------------------------------------------------------

=head2 processCredentials

Process the form where credentials (name, address, phone number and credit card information)
are entered.

=cut

sub processCredentials {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
	my $i18n    = WebGUI::International->new($session, $I18N);
    my @error;

    # Check credit card data
	push @error, $i18n->get( 'invalid card number'  ) unless $form->integer('cardNumber');
	push @error, $i18n->get( 'invalid cvv2'         ) if ($self->get('useCVV2') && !$form->integer('cvv2'));

	# Check if expDate and expYear have sane values
	my ($currentYear, $currentMonth) = $self->session->datetime->localtime;
    my $expires = $form->integer( 'expYear' ) . sprintf '%02d', $form->integer( 'expMonth' );
    my $now     = $currentYear                . sprintf '%02d', $currentMonth;

    push @error, $i18n->get('invalid expiration date') unless $expires =~ m{^\d{6}$};
    push @error, $i18n->get('expired expiration date') unless $expires >= $now;

	return \@error if scalar @error;
    # Everything ok process the actual data
    $self->{ _cardData } = {
        acct		=> $form->integer( 'cardNumber' ),
        expMonth	=> $form->integer( 'expMonth'   ),
        expYear		=> $form->integer( 'expYear'    ),
        cvv2		=> $form->integer( 'cvv2'       ),
    };

    return;
}

#-------------------------------------------------------------------

=head2 www_getCredentials ( $errors )

Build a templated form for asking the user for their credentials.

=head3 $errors

An array reference of errors to show the user.

=cut

sub www_getCredentials {
    my $self        = shift;
    my $errors      = shift;
    my $session     = $self->session;
    my $form        = $session->form;
    my $i18n        = WebGUI::International->new($session, $I18N);
    my $var = {};

# Process form errors
    $var->{errors} = [];
    if ($errors) {
        $var->{error_message} = $i18n->get('error occurred message');
        foreach my $error (@{ $errors} ) {
            push @{ $var->{errors} }, { error => $error };
        }
    }

    $self->appendCredentialVars($var);
    $self->appendCartVariables($var);

    my $template = WebGUI::Asset::Template->new($session, $self->get("credentialsTemplateId"));
    my $output;
    if (defined $template) {
        $template->prepare;
        $output = $template->process($var);
    }
    else {
        $output = $i18n->get('template gone');
    }

    return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_pay

Makes sure that the user has all the requirements for checking out, including
getting credentials, it processes the transaction and then displays a thank
you screen.

=cut

sub www_pay {
    my $self        = shift;
    my $session     = $self->session;
    # Check whether the user filled in the checkout form and process those.
    my $credentialsErrors = $self->processCredentials;

    # Go back to checkout form if credentials are not ok
    return $self->www_getCredentials( $credentialsErrors ) if $credentialsErrors;

    # Payment time!
    my $transaction = $self->processTransaction( );

	if ($transaction->get('isSuccessful')) {
	    return $transaction->thankYou();
	}

    # Payment has failed...
    return $self->displayPaymentError($transaction);
}

1;

