package WebGUI::Commerce::Payment::Cash;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::Payment::Cash

=head1 DESCRIPTION

Payment plug-in for cash transactions.

=cut

use strict;
use WebGUI::HTMLForm;
use WebGUI::Commerce::Payment;
use WebGUI::Commerce::Item;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Commerce::Payment);


#-------------------------------------------------------------------
sub connectionError {

	return undef;
}

#-------------------------------------------------------------------
sub checkoutForm {
	my ($self, $u, $f, %months, %years, $i18n);
	$self = shift;
	
	$i18n = WebGUI::International->new($self->session, 'CommercePaymentCash');

	$u = WebGUI::User->new($self->session,$self->session->user->userId);

	$f = WebGUI::HTMLForm->new($self->session);

	$f->selectBox(
                -name=>"paymentMethod",
                -label=>$i18n->get("payment method"),
                -value=>[$self->session->form->process("paymentMethod")],
                -defaultValue=>['cash'],
                -options=> { 'cash' => $i18n->get('cash'),
			     'check' => $i18n->get('check'),
			     'other' => $i18n->get('other'),
			   }
                );

	$f->text(
		-name	=> 'firstName',
		-label	=> $i18n->get('firstName'),
		-value	=> $self->session->form->process("firstName") || $u->profileField('firstName')
	);
	$f->text(
		-name	=> 'lastName',
		-label	=> $i18n->get('lastName'),
		-value	=> $self->session->form->process("lastName") || $u->profileField('lastName')
	);
	$f->text(
		-name	=> 'address',
		-label	=> $i18n->get('address'),
		-value	=> $self->session->form->process("address") || $u->profileField('homeAddress')
	);
	$f->text(
		-name	=> 'city',
		-label	=> $i18n->get('city'),
		-value	=> $self->session->form->process("city") || $u->profileField('homeCity')
	);
	$f->text(
		-name	=> 'state',
		-label	=> $i18n->get('state'),
		-value	=> $self->session->form->process("state") || $u->profileField('homeState')
	);
	$f->zipcode(
		-name	=> 'zipcode',
		-label	=> $i18n->get('zipcode'),
		-value	=> $self->session->form->process("zipcode") || $u->profileField('homeZip')
	);
	$f->country(
		-name=>"country",
		-label=>$i18n->get("country"),
		-value=>($self->session->form->process("country",'country') || $u->profileField("homeCountry") || 'United States')
	);
  $f->phone(
		-name=>"phone",
		-label=>$i18n->get("phone"),
		-defaultValue=>$u->profileField("homePhone"),
		-value=>$self->session->form->process("phone",'phone'),
	);
	$f->email(
		-name	=> 'email',
		-label	=> $i18n->get('email'),
		-value	=> $self->session->form->process("email",'email') || $u->profileField('email')
	);

	return $f->printRowsOnly;	
}

#-------------------------------------------------------------------
sub configurationForm {
	my ($self, $f, $i18n);
	$self = shift;
 	$i18n = WebGUI::International->new($self->session, 'CommercePaymentCash');

	$f = WebGUI::HTMLForm->new($self->session);

	$f->textarea(
		-name	=> $self->prepend('emailMessage'),
		-label	=> $i18n->get('emailMessage'),
		-value	=> $self->get('emailMessage')
		);

	$f->yesNo(
		-name	=> $self->prepend('completeTransaction'),
		-value 	=> ($self->get('completeTransaction') eq "0" ? 0 : $self->get('completeTransaction') || 1),
		-label 	=> $i18n->get('complete transaction'),
		-hoverHelp => $i18n->get('complete transaction description'),
		);
		
	return $self->SUPER::configurationForm($f->printRowsOnly);
}

#-------------------------------------------------------------------
sub confirmTransaction {

	return 0;
}

#-------------------------------------------------------------------

=head2 init ( namespace )

Constructor for the Cash plugin.

=head3 session

A copy of the session object

=head3 namespace

The namespace of the plugin.

=cut

sub init {
	my ($class, $self);
	$class = shift;
	my $session = shift;
	$self = $class->SUPER::init($session,'Cash');

	return $self;
}

#-------------------------------------------------------------------
sub gatewayId {
	my $self = shift;
	
	return $self->get('paymentMethod').":".$self->session->id->generate;
}


#-------------------------------------------------------------------
sub errorCode {
	my $self = shift;
	return $self->{_error}->{code};
}

#-------------------------------------------------------------------
sub name {
	return 'Cash';
}

#-------------------------------------------------------------------
sub namespace {
	my $self = shift;
	return $self->{_namespace};
}

#-------------------------------------------------------------------
sub normalTransaction {
	my ($self, $normal);
	$self = shift;
	$normal = shift;

	if ($normal) {
		my $i18n = WebGUI::International->new($self->session, 'CommercePaymentCash');
		$self->{_transactionParams} = {
			AMT		=> sprintf('%.2f', $normal->{amount}),
			DESCRIPTION	=> $normal->{description} || $i18n->get('no description'),
			INVOICENUMBER	=> $normal->{invoiceNumber},
			ORGID		=> $normal->{id},
		};
	}
	
	if ($self->get('completeTransaction')) {
		$self->{_transaction}->{status} = 'complete';
	}
	else {
		$self->{_transaction}->{status} = 'pending';
		$self->{_error}->{message} = 'Your transaction will be completed upon receipt of payment.';
		$self->{_error}->{code} = 1;
	}
}

#-------------------------------------------------------------------
sub shippingCost {
	my $self = shift;
	$self->{_shipping}->{cost} = shift;
}

#-------------------------------------------------------------------
sub shippingDescription {
	my $self = shift;
	$self->{_shipping}->{description} = shift;
}

#-------------------------------------------------------------------
sub supports {
	return {
		single		=> 1,
		recurring	=> 0,
	}
}

#-------------------------------------------------------------------
sub transactionCompleted {
	my $self = shift;
	return 1 if $self->{_transaction}->{status} eq 'complete';
}

#-------------------------------------------------------------------
sub transactionError {
	my $self = shift;
	return $self->{_error}->{message};
}

#-------------------------------------------------------------------
sub transactionPending {
	my $self = shift;
	return 1 if $self->{_transaction}->{status} eq 'pending';
}

#-------------------------------------------------------------------
sub validateFormData {
	my ($self, @error, $i18n, $currentYear, $currentMonth);
	$self = shift;

	$i18n = WebGUI::International->new($self->session,'CommercePaymentCash');

	push (@error, $i18n->get('invalid firstName')) unless ($self->session->form->process("firstName"));
	push (@error, $i18n->get('invalid lastName')) unless ($self->session->form->process("lastName"));
	push (@error, $i18n->get('invalid address')) unless ($self->session->form->process("address"));
	push (@error, $i18n->get('invalid city')) unless ($self->session->form->process("city"));
	push (@error, $i18n->get('invalid zip')) if ($self->session->form->process("zipcode") eq "" && $self->session->form->process("country") eq "United States");
	push (@error, $i18n->get('invalid email')) unless ($self->session->form->process("email"));
	
	unless (@error) {
		$self->{_paymentData} = {
			PAYMENTMETHOD	=> $self->session->form->process("paymentMethod"),
		};	
		
		$self->{_userData} = {
			STREET		=> $self->session->form->process("address"),
			ZIP		=> $self->session->form->process("zipcode"),
			CITY		=> $self->session->form->process("city"),
			FIRSTNAME	=> $self->session->form->process("firstName"),
			LASTNAME	=> $self->session->form->process("lastName"),
			EMAIL		=> $self->session->form->process("email"),
			STATE		=> $self->session->form->process("state"),
			COUNTRY		=> $self->session->form->process("country"),
			PHONE		=> $self->session->form->process("phone"),
		};

		return 0;
	}
			
	return \@error;
}

1;

