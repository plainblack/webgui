package WebGUI::Commerce::Payment::PayFlowPro;

use strict;
use WebGUI::Session;
use WebGUI::HTMLForm;
use WebGUI::Commerce::Payment;
use Tie::IxHash;
use PFProAPI qw( pfpro );
use WebGUI::International;

our @ISA = qw(WebGUI::Commerce::Payment);


#-------------------------------------------------------------------
sub cancelRecurringPayment {
	my ($self, $recurring);
	$self = shift;
	$recurring = shift;

	if ($recurring) {
		$self->{_type} = 'R';
		$self->{_recurring} = 1;
		$self->{_transactionParams} = {
			ORIGPROFILEID	=> $recurring->{id},
			ACTION 		=> 'C',
		};
	}

	return $self->submit;
}	

#-------------------------------------------------------------------
sub connectionError {
	my ($self, $resultCode);
	$self = shift;
	
	$resultCode = $self->resultCode;
	return $self->resultMessage if ($resultCode < 0);
	return undef;
}

#-------------------------------------------------------------------
sub checkoutForm {
	my ($self, $u, $f, %months, %years, $i18n);
	$self = shift;
	
	$i18n = WebGUI::International->new('CommercePaymentPayFlowPro');

	$u = WebGUI::User->new($session{user}{userId});

	$f = WebGUI::HTMLForm->new;
	$f->text(
		-name	=> 'name',
		-label	=> $i18n->get('name'),
		-value	=> $session{form}{name} || $u->profileField('firstName').' '.$u->profileField('lastName')
	);
	$f->text(
		-name	=> 'address',
		-label	=> $i18n->get('address'),
		-value	=> $session{form}{address} || $u->profileField('homeAddress')
	);
	$f->text(
		-name	=> 'city',
		-label	=> $i18n->get('city'),
		-value	=> $session{form}{city} || $u->profileField('homeCity')
	);
	$f->text(
		-name	=> 'state',
		-label	=> $i18n->get('state'),
		-value	=> $session{form}{state} || $u->profileField('homeState')
	);
	$f->zipcode(
		-name	=> 'zipcode',
		-label	=> $i18n->get('zipcode'),
		-value	=> $session{form}{zipcode} || $u->profileField('homeZip')
	);
	$f->email(
		-name	=> 'email',
		-label	=> $i18n->get('email'),
		-value	=> $session{form}{email} || $u->profileField('email')
	);
	$f->text(
		-name	=> 'cardNumber',
		-label	=> $i18n->get('cardNumber'),
		-value	=> $session{form}{cardNumber}
	);
	tie %months, "Tie::IxHash";
	%months = map {sprintf('%02d',$_) => sprintf('%02d',$_)} 1..12;
	tie %years, "Tie::IxHash";
	%years = map {substr($_,2,2) => $_} 2004..2099;
	$f->readOnly(
		-label	=> $i18n->get('expiration date'),
		-value	=> 
		WebGUI::Form::selectList({name => 'expMonth', options => \%months, value => [$session{form}{expMonth}]}).
		" / ".
		WebGUI::Form::selectList({name => 'expYear', options => \%years, value => [$session{form}{expYear}]})
	);
	$f->integer(
		-name	=> 'cvv2',
		-label	=> $i18n->get('cvv2'),
		-value  => $session{form}{cvv2}
	);

	return $f->printRowsOnly;	
}

#-------------------------------------------------------------------
sub configurationForm {
	my ($self, $f, $i18n);
	$self = shift;
 	$i18n = WebGUI::International->new('CommercePaymentPayFlowPro');

	$f = WebGUI::HTMLForm->new;
	$f->text(
		-name	=> $self->prepend('vendor'),
		-label	=> $i18n->get('vendor'),
		-value	=> $self->get('vendor')
		);
	$f->text(
		-name	=> $self->prepend('partner'),
		-label	=> $i18n->get('partner'),
		-value	=> $self->get('partner')
		);
	$f->text(
		-name	=> $self->prepend('username'),
		-label	=> $i18n->get('username'),
		-value	=> $self->get('username')
		);
	$f->text(
		-name	=> $self->prepend('password'),
		-label	=> $i18n->get('password'),
		-value	=> $self->get('password')
		);
	$f->yesNo(
		-name	=> $self->prepend('testModeEnabled'),
		-label	=> $i18n->get('test mode'),
		-value	=> $self->get('testModeEnabled'),
		-subText=> $i18n->get('testModeEnabled')
		);
		
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub confirmTransaction {
	# This function should never be called with site side payment gateways!
	return 0;
}

#-------------------------------------------------------------------
sub init {
	my ($class, $self);
	$class = shift;
		
	$self = $class->SUPER::init('PayFlowPro');

	return $self;
}

#-------------------------------------------------------------------
sub gatewayId {
	my $self = shift;
	
	return $self->{_response}->{PROFILEID} if   $self->{_recurring};
	return $self->{_response}->{PNREF};
}

#-------------------------------------------------------------------
sub getRecurringPaymentStatus {
	my ($self, $term, $recurringId, $response, %paymentHistory);
	$self = shift;
	$recurringId = shift;
	$term = shift;
	
	if ($recurringId) {
		$self->{_type} = 'R';
		$self->{_recurring} = 1;
		$self->{_transactionParams} = {
			ORIGPROFILEID	=> $recurringId,
			PAYMENTHISTORY	=> 'Y',
			ACTION 		=> 'I',
		};
	}

	$self->submit;

	$response = $self->{_response};

	# Process the response
	if ($term) {
		return undef unless (defined $response->{'P_RESULT'.$term});
		return {
			resultCode 	=> $response->{'P_RESULT'.$term},
			gatewayId	=> $response->{'P_PNREF'.$term},
			transferState	=> $response->{'P_TRANSTATE'.$term},
			transferDate	=> $response->{'P_TRANSTIME'.$term},
			amount		=> $response->{'P_AMOUNT'.$term},
			};
	}
	
	$term = 1;
	while (defined $response->{'P_RESULT'.$term}) {
		$paymentHistory{$term} = {
			resultCode 	=> $response->{'P_RESULT'.$term},
			gatewayId	=> $response->{'P_PNREF'.$term},
			transferState	=> $response->{'P_TRANSTATE'.$term},
			transferDate	=> $response->{'P_TRANSTIME'.$term},
			amount		=> $response->{'P_AMT'.$term},
			};
		$term++;
	}

	return \%paymentHistory;
}
	
#-------------------------------------------------------------------
sub errorCode {
	my ($self, $resultCode);
	$self = shift;
	
	$resultCode = $self->{_response}->{RESULT};
	return $self->{_response}->{TRXRESULT} if ($resultCode == 36 && $self->{_recurring} && $self->{_response}->{TRXRESULT});
	return $resultCode unless ($resultCode eq '0');
	return undef;
}

#-------------------------------------------------------------------
sub name {
	return WebGUI::International::get('module name', "CommercePaymentPayFlowPro");
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
		$self->{_type} = 'S';
		$self->{_recurring} = 0;
		$self->{_transactionParams} = {
			AMT		=> sprintf('%.2f', $normal->{amount}),
			COMMENT1	=> $normal->{description},
			COMMENT2	=> $normal->{invoiceNumber},
			ORGID		=> $normal->{id},
		};
	}

	return $self->submit;
}

#-------------------------------------------------------------------
sub recurringTransaction {
	my ($self, $recurring);
	$self = shift;
	$recurring = shift;

	my %resolve = (
		Weekly		=> 'WEEK',
		BiWeekly	=> 'BIWK',
		FourWeekly	=> 'FRWK',
		Monthly		=> 'MONT',
		Quarterly	=> 'QTER',
		HalfYearly	=> 'SMYR',
		Yearly		=> 'YEAR',
		);

	if ($recurring) {
		$self->{_type} = 'R';
		$self->{_recurring} = 1;
		$self->{_transactionParams} = {
			START		=> $recurring->{start} || WebGUI::DateTime::epochToHuman(WebGUI::DateTime::addToDate(time, 0, 0, 1), '%m%d%y'),
			AMT		=> sprintf('%.2f', $recurring->{amount}),
			TERM		=> $recurring->{term},
			PAYPERIOD	=> $resolve{$recurring->{payPeriod}},
			PROFILENAME	=> $recurring->{profilename},
			COMMENT1	=> $recurring->{description},
			COMMENT2	=> $recurring->{invoiceNumber},
			ORGID		=> $recurring->{id},
			ACTION		=> 'A',
		};
		$self->{_transactionParams}->{OPTIONALTRX}  = 'A' if ($recurring->{checkCard});
	}

	return $self->submit;
}	

#-------------------------------------------------------------------
sub resultCode {
	my $self = shift;

	return $self->{_response}->{RESULT};
}

#-------------------------------------------------------------------
sub resultMessage {
	my $self = shift;

	 return $self->{_response}->{RESPMSG};
}

#-------------------------------------------------------------------
sub submit {
	my ($payflow, $self, $purchase, %properties, $expirationDate);
	$self = shift;
	$purchase = shift;

my 	$server = 'payflow.verisign.com';
	$server = 'test-payflow.verisign.com' if $self->get('testModeEnabled');
my 	$port = 443;
my	%cardData = %{$self->{_cardData}} if $self->{_cardData};
my	%userData = %{$self->{_userData}} if $self->{_userData};
my	%specificTranasctionParams = %{$self->{_transactionParams}};
my	%baseParams = (
		USER		=> $self->get('username'),
		VENDOR		=> $self->get('vendor'),
		PARTNER		=> $self->get('partner'),
		PWD		=> $self->get('password'),

		TRXTYPE		=> $self->{_type},
		TENDER		=> 'C',
	);

	%properties = (%baseParams, %specificTranasctionParams, %userData, %cardData);	

my	( $response, $resultstr ) = pfpro( \%properties, $server, $port );

	$self->{_response} = $response;
}

#-------------------------------------------------------------------
sub supports {
	return {
		single		=> 1,
		recurring	=> 1,
	}
}

#-------------------------------------------------------------------
sub transactionCompleted {
	my ($self) = shift;
	return ($self->{_response}->{RESULT} eq '0');
}

#-------------------------------------------------------------------
sub transactionError {
	my ($self, $resultCode);
	$self = shift;
	
	$resultCode = $self->resultCode;
	return $self->{_response}->{TRXRESPMSG} if ($resultCode == 36 && $self->{_recurring} && $self->{_response}->{TRXRESULT});
	return $self->resultMessage if ($resultCode > 0);
	return undef;
}

#-------------------------------------------------------------------
sub transactionPending {
	return ($_[0]->errorCode == 126);
}

#-------------------------------------------------------------------
sub validateFormData {
	my ($self, @error, $i18n, $currentYear, $currentMonth);
	$self = shift;

	$i18n = WebGUI::International->new('CommercePaymentPayFlowPro');
	
	push (@error, $i18n->get('invalid name')) unless ($session{form}{name});
	push (@error, $i18n->get('invalid address')) unless ($session{form}{address});
	push (@error, $i18n->get('invalid city')) unless ($session{form}{city});
	push (@error, $i18n->get('invalid zip')) unless ($session{form}{zipcode});
	push (@error, $i18n->get('invalid email')) unless ($session{form}{email});
	
	push (@error, $i18n->get('invalid card number')) unless ($session{form}{cardNumber} =~ /^\d+$/);	
	push (@error, $i18n->get('invalid cvv2')) unless ($session{form}{cvv2} =~ /^\d+$/);

	($currentYear, $currentMonth) = WebGUI::DateTime::localtime;
	$currentYear -= 2000;

	# Check if expDate and expYear have sane values
	unless (($session{form}{expMonth} =~ /^(0[1-9]|1[0-2])$/) && ($session{form}{expYear} =~ /^\d\d$/)) {
		push (@error, $i18n->get('invalid expiration date'));
	} elsif (($session{form}{expYear} < $currentYear) || 
		(($session{form}{expYear} == $currentYear) && ($session{form}{expMonth} < $currentMonth))) {
		push (@error, $i18n->get('invalid expiration date'));
	}

	unless (@error) {
		$self->{_cardData} = {
			ACCT		=> $session{form}{cardNumber},
			EXPDATE		=> $session{form}{expMonth}.$session{form}{expYear},
			CVV2		=> $session{form}{cvv2},
		};

		$self->{_userData} = {
			STREET		=> $session{form}{address},
			ZIP		=> $session{form}{zipcode},
			CITY		=> $session{form}{city},
			NAME		=> $session{form}{name},
			EMAIL		=> $session{form}{email},
			STATE		=> $session{form}{state},
		};

		return 0;
	}
			
	return \@error;
}

1;

