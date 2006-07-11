package WebGUI::Commerce::Payment::ITransact;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::Payment::ITransact

=head1 DESCRIPTION

Payment plug-in for ITransact payment gateway.

=cut

use strict;
use WebGUI::HTMLForm;
use WebGUI::Commerce::Payment;
use WebGUI::Commerce::Item;
use Tie::IxHash;
use WebGUI::International;
use LWP::UserAgent;
use XML::Simple;
use HTTP::Cookies;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Commerce::Payment);

#-------------------------------------------------------------------
sub _resolveRecipe {
	my %resolve = (
		Weekly		=> 'weekly',
		BiWeekly	=> 'biweekly',
		FourWeekly	=> 'fourweekly',
		Monthly		=> 'monthly',
		Quarterly	=> 'quarterly',
		HalfYearly	=> 'halfyearly',
		Yearly		=> 'yearly',
		);
	
	return $resolve{$_[0]};
}

#-------------------------------------------------------------------
sub cancelRecurringPayment {
	my ($self, $recurring, $userAgent, $request, $response);
	$self = shift;
	$recurring = shift;

	if ($recurring) {
		$self->{_recurring} = 1;

		my $itemProperties = $recurring->{transaction}->getItems->[0];
		my $item = WebGUI::Commerce::Item->new($self->session,$itemProperties->{itemId}, $itemProperties->{itemType});
		my $recipe = _resolveRecipe($item->duration);
		    
		# Set up a user agent that uses cookies and allows POST redirects
		$userAgent = LWP::UserAgent->new;
		$userAgent->agent("Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.5) Gecko/20041107 Firefox/1.0");
		push @{ $userAgent->requests_redirectable }, 'POST';
		$userAgent->cookie_jar({});

		# Login to iTransact
		$request = HTTP::Request->new(POST => 'https://secure.paymentclearing.com/cgi-bin/rc/sess.cgi');
		$request->content_type('application/x-www-form-urlencoded');
		$request->content('mid='.$self->get('vendorId').';pwd='.$self->get('password').';cookie_precheck=0');

		$response = $userAgent->request($request);

		# Check the outcome of the response
		if ($response->is_success) {
#			print "FIRST PAGE SUCCESS!\n";
#			print "(".$response->base.")\n";
		} else {
			$self->session->errorHandler->fatalError(
				'Connection Error while trying to cancel transaction '.$recurring->{transaction}->transactionId." \n".
				"Could not reach login page.\n".
				"(".$response->base.")\n".
				$response->status_line. "\n");
		}


		# Post cancelation 
		my $request = HTTP::Request->new(POST => 'https://secure.paymentclearing.com/cgi-bin/rc/recur/update/update.cgi');
		$request->content_type('application/x-www-form-urlencoded');
		$request->content(
			'reps=0;'.			# Set number of remaining repetition to zero in order to cancel
			'recipe_code='.$recipe.';'.	
			'xid='.$recurring->{id});

		my $response = $userAgent->request($request);

		# Check the outcome of the response
		if ($response->is_success) {
#			print "CANCELATION PAGE SUCCESS!\n";
#			print "(".$response->base.")\n";
		} else {
			$self->session->errorHandler->fatalError(
				'Connection Error while trying to cancel transaction '.$recurring->{transaction}->transactionId." \n".
				"(".$response->base.")\n".
				$response->status_line. "\n");
		}
	}
}	

#-------------------------------------------------------------------
sub connectionError {
	my ($self, $resultCode);
	$self = shift;

	return $self->resultMessage if ($self->{_connectionError});
	return undef;
}

#-------------------------------------------------------------------
sub checkoutForm {
	my ($self, $u, $f, %months, %years, $i18n);
	$self = shift;
	
	$i18n = WebGUI::International->new($self->session, 'CommercePaymentITransact');

	$u = WebGUI::User->new($self->session,$self->session->user->userId);

	$f = WebGUI::HTMLForm->new($self->session);
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
		-value	=> $self->session->form->process("email") || $u->profileField('email')
	);
	$f->text(
		-name	=> 'cardNumber',
		-label	=> $i18n->get('cardNumber'),
		-value	=> $self->session->form->process("cardNumber")
	);
	tie %months, "Tie::IxHash";
	%months = map {sprintf('%02d',$_) => sprintf('%02d',$_)} 1..12;
	tie %years, "Tie::IxHash";
	%years = map {$_ => $_} 2004..2099;
	$f->readOnly(
		-label	=> $i18n->get('expiration date'),
		-value	=> 
		WebGUI::Form::selectBox($self->session,{name => 'expMonth', options => \%months, value => [$self->session->form->process("expMonth")]}).
		" / ".
		WebGUI::Form::selectBox($self->session,{name => 'expYear', options => \%years, value => [$self->session->form->process("expYear")]})
	);
	$f->integer(
		-name	=> 'cvv2',
		-label	=> $i18n->get('cvv2'),
		-value  => $self->session->form->process("cvv2")
	) if ($self->get('useCVV2'));

	return $f->printRowsOnly;	
}

#-------------------------------------------------------------------
sub configurationForm {
	my ($self, $f, $i18n);
	$self = shift;
 	$i18n = WebGUI::International->new($self->session, 'CommercePaymentITransact');

	$f = WebGUI::HTMLForm->new($self->session);
	$f->text(
		-name	=> $self->prepend('vendorId'),
		-label	=> $i18n->get('vendorId'),
		-value	=> $self->get('vendorId')
		);
	$f->text(
		-name	=> $self->prepend('password'),
		-label	=> $i18n->get('password'),
		-value	=> $self->get('password')
		);
	$f->yesNo(
		-name	=> $self->prepend('useCVV2'),
		-label	=> $i18n->get('use cvv2'),
		-value	=> $self->get('useCVV2'),
		);
	$f->textarea(
		-name	=> $self->prepend('emailMessage'),
		-label	=> $i18n->get('emailMessage'),
		-value	=> $self->get('emailMessage')
		);
	$f->readOnly(
		-value	=> '<br />'
		);
	if ($self->get('vendorId')) {
		$f->readOnly(
			-value => '<a target="_blank" href="https://secure.paymentclearing.com/support/login.html">'.$i18n->get('show terminal').'</a>'
			);
	}
	$f->readOnly(
		-value	=> '<br />'
		);
	$f->readOnly(
		-value	=> $i18n->get('extra info').'<br /><b>https://'.$self->session->config->get("defaultSitename").'/?op=confirmRecurringTransaction;gateway='.$self->namespace
		);
		
	return $self->SUPER::configurationForm($f->printRowsOnly);
}

#-------------------------------------------------------------------
sub confirmRecurringTransaction {
	#### !!!Site checken!!! ####
	my $self = shift;
	
	my $transaction = WebGUI::Commerce::Transaction->getByGatewayId($self->session->form->process("orig_xid"), $self->namespace);
	my $itemProperties = $transaction->getItems->[0];
	my $item = WebGUI::Commerce::Item->new($self->session,$itemProperties->{itemId}, $itemProperties->{itemType});
	
	my $startEpoch = $self->session->datetime->setToEpoch(sprintf("%4d-%02d-%02d %02d:%02d:%02d", unpack('a4a2a2a2a2a2', $self->session->form->process("start_date"))));
	my $currentEpoch = $self->session->datetime->setToEpoch(sprintf("%4d-%02d-%02d %02d:%02d:%02d", unpack('a4a2a2a2a2a2', $self->session->form->process("when"))));
	
	$self->session->db->write("delete from ITransact_recurringStatus where gatewayId=".$self->session->db->quote($self->session->form->process("orig_xid")));
	$self->session->db->write("insert into ITransact_recurringStatus ".
		"(gatewayId, initDate, lastTransaction, status, errorMessage, recipe) values ".
		"(".$self->session->db->quote($self->session->form->process("orig_xid")).", $startEpoch, $currentEpoch, ".$self->session->db->quote($self->session->form->process("status")).", ".$self->session->db->quote($self->session->form->process("error_message")).
		", ".$self->session->db->quote($self->session->form->process("recipe_name")).")");
}

#-------------------------------------------------------------------
sub confirmTransaction {
	# This function should never be called with site side payment gateways!
	return 0;
}

#-------------------------------------------------------------------

=head2 init ( namespace )

Constructor for the ITransact plugin.

=head3 session

A copy of the session object

=head3 namespace

The namespace of the plugin.

=cut

sub init {
	my ($class, $self);
	$class = shift;
	my $session = shift;
	$self = $class->SUPER::init($session,'ITransact');

	return $self;
}

#-------------------------------------------------------------------
sub gatewayId {
	my $self = shift;
	
	return $self->{_response}->{XID};
}

#-------------------------------------------------------------------
sub getRecurringPaymentStatus {
	my ($self, $term, $recurringId, $response, %paymentHistory);
	$self = shift;
	$recurringId = shift;
	$term = shift || 1;
	
	my %resolve = (
		weekly		=> 7*3600*24,
		biweekly	=> 14*3600*24,
		fourweekly	=> 28*3600*24,
		monthly		=> 30*3600*24,
		quarterly	=> 91*3600*24,
		halfyearly	=> 182*3600*24,
		yearly		=> 365*3600*24
	);

	my $transactionData = $self->session->db->quickHashRef("select * from ITransact_recurringStatus where gatewayId=".$self->session->db->quote($recurringId));
	unless ($transactionData->{recipe}) { # if for some reason there's no transaction data, we shouldn't calc anything
		$self->session->errorHandler->error("For some reason recurring transaction $recurringId doesn't have any recurring status transaction data. This is most likely because you don't have the Recurring Postback URL set in your ITransact virtual terminal.");
		return undef;
	}
        my $lastTerm = int(($transactionData->{lastTransaction} - $transactionData->{initDate}) / $resolve{$transactionData->{recipe}}) + 1;
		
	# Process the response
	
	if ($lastTerm > $term) {
		$paymentHistory{resultCode} = 0;
	} elsif ($lastTerm == $term) {
		$paymentHistory{resultCode} = $transactionData->{status}.' '.$transactionData->{errorMessage};
		$paymentHistory{resultCode} = 0 if $transactionData->{status} eq 'OK';
	} else {
		return undef;
	}
		
	return \%paymentHistory;
}

#-------------------------------------------------------------------
sub errorCode {
	my ($self, $resultCode);
	$self = shift;

	$resultCode = $self->{_response}->{Status};
	return $resultCode unless ($resultCode eq 'OK');
	return undef;
}

#-------------------------------------------------------------------
sub name {
	return 'ITransact';
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
		my $i18n = WebGUI::International->new($self->session, 'CommercePaymentITransact');
		$self->{_recurring} = 0;
		$self->{_transactionParams} = {
			AMT		=> sprintf('%.2f', $normal->{amount}),
			DESCRIPTION	=> $self->session->url->escape($normal->{description}) || $i18n->get('no description'),
			INVOICENUMBER	=> $normal->{invoiceNumber},
			ORGID		=> $normal->{id},
		};
	}

	return $self->submit;
}

#-------------------------------------------------------------------
sub recurringTransaction {
	my ($self, $recurring, $initialAmount);
	$self = shift;
	$recurring = shift;


	if ($recurring) {
		# initial amount = (daysInMonth - dayInMonth) / daysInMonth * amount
		$initialAmount = ($self->session->datetime->getDaysInMonth(time) - ($self->session->datetime->localtime)[2])*$recurring->{amount}/$self->session->datetime->getDaysInMonth(time);
		$initialAmount = $recurring->{amount} if ($initialAmount < 1);
		$self->{_recurring} = 1;
		my $i18n = WebGUI::International->new($self->session, 'CommercePaymentITransact');
		$self->{_transactionParams} = {
			START		=> $recurring->{start} || $self->session->datetime->epochToHuman($self->session->datetime->addToDate(time, 0, 0, 1), '%m%d%y'),
			AMT		=> sprintf('%.2f', $recurring->{amount}),
			INITIALAMT	=> sprintf('%.2f', $initialAmount),
			TERM		=> $recurring->{term} || 9999,
			RECIPE		=> _resolveRecipe($recurring->{payPeriod}),
			DESCRIPTION	=> $self->session->url->escape($recurring->{description}) || $i18n->get('no description'),
			INVOICENUMBER	=> $recurring->{invoiceNumber},
			ORGID		=> $recurring->{id},
		};
	}

	return $self->submit;
}	

#-------------------------------------------------------------------
sub resultCode {
	my $self = shift;

	return $self->{_response}->{Status};
}

#-------------------------------------------------------------------
sub resultMessage {
	my $self = shift;
	
	return $self->{_resultMessage} if ($self->{_connectionError});
	return $self->{_response}->{ErrorMessage};
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
sub submit {
	my ($self, $xml, $items);
	$self = shift;

my	%cardData = %{$self->{_cardData}} if $self->{_cardData};
my	%userData = %{$self->{_userData}} if $self->{_userData};
my	%transactionData = %{$self->{_transactionParams}};

	# Set up the XML.

	$xml = 
'<?xml version="1.0"?>'.
"<SaleRequest>
  <CustomerData>
    <Email>$userData{EMAIL}</Email>
    <BillingAddress>
      <Address1>$userData{STREET}</Address1>
      <FirstName>$userData{FIRSTNAME}</FirstName>
      <LastName>$userData{LASTNAME}</LastName>
      <City>$userData{CITY}</City>
      <State>$userData{STATE}</State>
      <Zip>$userData{ZIP}</Zip>
      <Country>$userData{COUNTRY}</Country>
      <Phone>$userData{PHONE}</Phone>
    </BillingAddress>
    <AccountInfo>
      <CardInfo>
  	<CCNum>$cardData{ACCT}</CCNum>
   	<CCMo>$cardData{EXPMONTH}</CCMo>
    	<CCYr>$cardData{EXPYEAR}</CCYr>\n";
	
	$xml .= "<CVV2Number>$cardData{CVV2}</CVV2Number>\n" if $self->get('useCVV2');
#      	  <CVV2Illegible>1</CVV2Illegible> <!-- .Submit only if CVV number is illegible. -->
	$xml .=
"      </CardInfo> 
    </AccountInfo>
  </CustomerData>
  <TransactionData>
    <VendorId>".$self->get('vendorId')."</VendorId>
    <VendorPassword>".$self->get('password')."</VendorPassword>
    <HomePage>".$self->session->setting->get("companyURL")."</HomePage>\n";

	if ($self->{_recurring}) {
		$xml .=
"    <RecurringData>
      <RecurRecipe>$transactionData{RECIPE}</RecurRecipe>
      <RecurReps>$transactionData{TERM}</RecurReps>
      <RecurTotal>$transactionData{AMT}</RecurTotal>
      <RecurDesc>$transactionData{DESCRIPTION}</RecurDesc>
    </RecurringData>\n";
	};

	$xml .=
"    <EmailText>
      <EmailTextItem>".$self->get('emailMessage')."</EmailTextItem>
      <EmailTextItem>ID: $transactionData{ORGID}</EmailTextItem>
    </EmailText>
    <OrderItems>\n";

	$items = WebGUI::Commerce::Transaction->new($self->session, $transactionData{ORGID})->getItems;
	foreach (@{$items}) {
		my $data = $_->{itemName};
	#	$data =~ s/&/&amp;/sg;
	#	$data =~ s/</&lt;/sg;
	#	$data =~ s/>/&gt;/sg;
	#	$data =~ s/"/&quot;/sg;
		$data =~ tr/A-Za-z0-9 //dc;
		my $itemPrice = $_->{amount} / $_->{quantity};
		$xml .= 
"   <Item>
        <Description>".$data."</Description>
	<Cost>".sprintf('%.2f', $itemPrice)."</Cost>
	<Qty>".$_->{quantity}."</Qty>
      </Item>\n";
	}

	if ($self->{_shipping}->{cost}) {
		$xml .=
"     <Item>
        <Description>Shipping cost. ".$self->{_shipping}->{description}."</Description>
	<Cost>".sprintf('%.2f', $self->{_shipping}->{cost})."</Cost>
	<Qty>1</Qty>
      </Item>\n";
	};

	$xml .=
"    </OrderItems>
  </TransactionData>
</SaleRequest>";

##
## Nice for debugging
##
# open(DAT,">/tmp/itransact.xml") || die("Cannot Open File");
# print DAT "$xml";
# close(DAT);
#

my	$xmlTransactionScript = 'https://secure.paymentclearing.com/cgi-bin/rc/xmltrans.cgi';

	# Set up LWP to post the XML to iTransact.
my	$userAgent = LWP::UserAgent->new;
	$userAgent->agent("WebGUI ");

my	$request = HTTP::Request->new(POST => $xmlTransactionScript);
	$request->content_type('application/x-www-form-urlencoded');
	$request->content('xml='.$xml);

my	$response = $userAgent->request($request);

	if ($response->is_success) {
		# We got some XML back from iTransact, now parse it.
my		$xmlParser = XML::Simple->new;
my		$transactionResult = $xmlParser->XMLin($response->content);

		unless (defined $transactionResult->{TransactionData}) {
			# Some error occurred
			$self->{_transactionError} = 1;
			$self->{_response} = $transactionResult;
			$self->{_resultMessage} = $self->{_response}->{ErrorMessage};
		} else {
			$self->{_response} = $transactionResult->{TransactionData};
		}
	} else {
		# Connection Error
		$self->{_connectionError} = 1;
		$self->{_resultMessage} = $response->status_line;
	}
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

	return ($self->{_response}->{Status} eq 'OK');
}

#-------------------------------------------------------------------
sub transactionError {
	my ($self, $resultCode);
	$self = shift;

	$resultCode = $self->resultCode;
	return $self->resultMessage if ($resultCode ne 'OK');
	return undef;
}

#-------------------------------------------------------------------
sub transactionPending {
	return 0;
}

#-------------------------------------------------------------------
sub validateFormData {
	my ($self, @error, $i18n, $currentYear, $currentMonth);
	$self = shift;

	$i18n = WebGUI::International->new($self->session,'CommercePaymentITransact');

	push (@error, $i18n->get('invalid firstName')) unless ($self->session->form->process("firstName"));
	push (@error, $i18n->get('invalid lastName')) unless ($self->session->form->process("lastName"));
	push (@error, $i18n->get('invalid address')) unless ($self->session->form->process("address"));
	push (@error, $i18n->get('invalid city')) unless ($self->session->form->process("city"));
	push (@error, $i18n->get('invalid zip')) if ($self->session->form->process("zipcode") eq "" && $self->session->form->process("country") eq "United States");
	push (@error, $i18n->get('invalid email')) unless ($self->session->form->process("email"));
	
	push (@error, $i18n->get('invalid card number')) unless ($self->session->form->process("cardNumber") =~ /^\d+$/);	
	push (@error, $i18n->get('invalid cvv2')) if ($self->session->form->process("cvv2") !~ /^\d+$/ && $self->get('useCVV2'));

	($currentYear, $currentMonth) = $self->session->datetime->localtime;

	# Check if expDate and expYear have sane values
	unless (($self->session->form->process("expMonth") =~ /^(0[1-9]|1[0-2])$/) && ($self->session->form->process("expYear") =~ /^\d\d\d\d$/)) {
		push (@error, $i18n->get('invalid expiration date'));
	} elsif (($self->session->form->process("expYear") < $currentYear) || 
		(($self->session->form->process("expYear") == $currentYear) && ($self->session->form->process("expMonth") < $currentMonth))) {
		push (@error, $i18n->get('invalid expiration date'));
	}

	unless (@error) {
		$self->{_cardData} = {
			ACCT		=> $self->session->form->process("cardNumber"),
			EXPMONTH	=> $self->session->form->process("expMonth"),
			EXPYEAR		=> $self->session->form->process("expYear"),
			CVV2		=> $self->session->form->process("cvv2"),
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

