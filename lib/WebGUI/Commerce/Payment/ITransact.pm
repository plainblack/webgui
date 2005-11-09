package WebGUI::Commerce::Payment::ITransact;

use strict;
use WebGUI::Session;
use WebGUI::HTMLForm;
use WebGUI::Commerce::Payment;
use WebGUI::Commerce::Item;
use WebGUI::URL;
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
		my $item = WebGUI::Commerce::Item->new($itemProperties->{itemId}, $itemProperties->{itemType});
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
			WebGUI::ErrorHandler::fatalError(
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
			WebGUI::ErrorHandler::fatalError(
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
	
	$i18n = WebGUI::International->new('CommercePaymentITransact');

	$u = WebGUI::User->new($session{user}{userId});

	$f = WebGUI::HTMLForm->new;
	$f->text(
		-name	=> 'firstName',
		-label	=> $i18n->get('firstName'),
		-value	=> $session{form}{firstName} || $u->profileField('firstName')
	);
	$f->text(
		-name	=> 'lastName',
		-label	=> $i18n->get('lastName'),
		-value	=> $session{form}{lastName} || $u->profileField('lastName')
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
	my %countries;
	tie %countries, 'Tie::IxHash';
	%countries = (
'Afghanistan' => 'Afghanistan',
'Albania' => 'Albania',
'Algeria' => 'Algeria',
'American Samoa' => 'American Samoa',
'Andorra' => 'Andorra',
'Anguilla' => 'Anguilla',
'Antarctica' => 'Antarctica',
'Antigua And Barbuda' => 'Antigua And Barbuda',
'Argentina' => 'Argentina',
'Armenia' => 'Armenia',
'Aruba' => 'Aruba',
'Australia' => 'Australia',
'Austria' => 'Austria',
'Azerbaijan' => 'Azerbaijan',
'Bahamas' => 'Bahamas',
'Bahrain' => 'Bahrain',
'Bangladesh' => 'Bangladesh',
'Barbados' => 'Barbados',
'Belarus' => 'Belarus',
'Belgium' => 'Belgium',
'Belize' => 'Belize',
'Benin' => 'Benin',
'Bermuda' => 'Bermuda',
'Bhutan' => 'Bhutan',
'Bolivia' => 'Bolivia',
'Bosnia and Herzegovina' => 'Bosnia and Herzegovina',
'Botswana' => 'Botswana',
'Bouvet Island' => 'Bouvet Island',
'Brazil' => 'Brazil',
'British Indian Ocean Territory' => 'British Indian Ocean Territory',
'Brunei Darussalam' => 'Brunei Darussalam',
'Bulgaria' => 'Bulgaria',
'Burkina Faso' => 'Burkina Faso',
'Burundi' => 'Burundi',
'Cambodia' => 'Cambodia',
'Cameroon' => 'Cameroon',
'Canada' => 'Canada',
'Cape Verde' => 'Cape Verde',
'Cayman Islands' => 'Cayman Islands',
'Central African Republic' => 'Central African Republic',
'Chad' => 'Chad',
'Chile' => 'Chile',
'China' => 'China',
'Christmas Island' => 'Christmas Island',
'Cocos (Keeling) Islands' => 'Cocos (Keeling) Islands',
'Colombia' => 'Colombia',
'Comoros' => 'Comoros',
'Congo' => 'Congo',
'Congo, the Democratic Republic of the' => 'Congo, the Democratic Republic of the',
'Cook Islands' => 'Cook Islands',
'Costa Rica' => 'Costa Rica',
'Cote d\'Ivoire' => 'Cote d\'Ivoire',
'Croatia' => 'Croatia',
'Cyprus' => 'Cyprus',
'Czech Republic' => 'Czech Republic',
'Denmark' => 'Denmark',
'Djibouti' => 'Djibouti',
'Dominica' => 'Dominica',
'Dominican Republic' => 'Dominican Republic',
'East Timor' => 'East Timor',
'Ecuador' => 'Ecuador',
'Egypt' => 'Egypt',
'El Salvador' => 'El Salvador',
'England' => 'England',
'Equatorial Guinea' => 'Equatorial Guinea',
'Eritrea' => 'Eritrea',
'Espana' => 'Espana',
'Estonia' => 'Estonia',
'Ethiopia' => 'Ethiopia',
'Falkland Islands' => 'Falkland Islands',
'Faroe Islands' => 'Faroe Islands',
'Fiji' => 'Fiji',
'Finland' => 'Finland',
'France' => 'France',
'French Guiana' => 'French Guiana',
'French Polynesia' => 'French Polynesia',
'French Southern Territories' => 'French Southern Territories',
'Gabon' => 'Gabon',
'Gambia' => 'Gambia',
'Georgia' => 'Georgia',
'Germany' => 'Germany',
'Ghana' => 'Ghana',
'Gibraltar' => 'Gibraltar',
'Great Britain' => 'Great Britain',
'Greece' => 'Greece',
'Greenland' => 'Greenland',
'Grenada' => 'Grenada',
'Guadeloupe' => 'Guadeloupe',
'Guam' => 'Guam',
'Guatemala' => 'Guatemala',
'Guinea' => 'Guinea',
'Guinea-Bissau' => 'Guinea-Bissau',
'Guyana' => 'Guyana',
'Haiti' => 'Haiti',
'Heard and Mc Donald Islands' => 'Heard and Mc Donald Islands',
'Honduras' => 'Honduras',
'Hong Kong' => 'Hong Kong',
'Hungary' => 'Hungary',
'Iceland' => 'Iceland',
'India' => 'India',
'Indonesia' => 'Indonesia',
'Ireland' => 'Ireland',
'Israel' => 'Israel',
'Italy' => 'Italy',
'Jamaica' => 'Jamaica',
'Japan' => 'Japan',
'Jordan' => 'Jordan',
'Kazakhstan' => 'Kazakhstan',
'Kenya' => 'Kenya',
'Kiribati' => 'Kiribati',
'Korea, Republic of' => 'Korea, Republic of',
'Korea (South)' => 'Korea (South)',
'Kuwait' => 'Kuwait',
'Kyrgyzstan' => 'Kyrgyzstan',
"Lao People's Democratic Republic" => "Lao People's Democratic Republic",
'Latvia' => 'Latvia',
'Lebanon' => 'Lebanon',
'Lesotho' => 'Lesotho',
'Liberia' => 'Liberia',
'Libya' => 'Libya',
'Liechtenstein' => 'Liechtenstein',
'Lithuania' => 'Lithuania',
'Luxembourg' => 'Luxembourg',
'Macau' => 'Macau',
'Macedonia' => 'Macedonia',
'Madagascar' => 'Madagascar',
'Malawi' => 'Malawi',
'Malaysia' => 'Malaysia',
'Maldives' => 'Maldives',
'Mali' => 'Mali',
'Malta' => 'Malta',
'Marshall Islands' => 'Marshall Islands',
'Martinique' => 'Martinique',
'Mauritania' => 'Mauritania',
'Mauritius' => 'Mauritius',
'Mayotte' => 'Mayotte',
'Mexico' => 'Mexico',
'Micronesia, Federated States of' => 'Micronesia, Federated States of',
'Moldova, Republic of' => 'Moldova, Republic of',
'Monaco' => 'Monaco',
'Mongolia' => 'Mongolia',
'Montserrat' => 'Montserrat',
'Morocco' => 'Morocco',
'Mozambique' => 'Mozambique',
'Myanmar' => 'Myanmar',
'Namibia' => 'Namibia',
'Nauru' => 'Nauru',
'Nepal' => 'Nepal',
'Netherlands' => 'Netherlands',
'Netherlands Antilles' => 'Netherlands Antilles',
'New Caledonia' => 'New Caledonia',
'New Zealand' => 'New Zealand',
'Nicaragua' => 'Nicaragua',
'Niger' => 'Niger',
'Nigeria' => 'Nigeria',
'Niue' => 'Niue',
'Norfolk Island' => 'Norfolk Island',
'Northern Ireland' => 'Northern Ireland',
'Northern Mariana Islands' => 'Northern Mariana Islands',
'Norway' => 'Norway',
'Oman' => 'Oman',
'Pakistan' => 'Pakistan',
'Palau' => 'Palau',
'Panama' => 'Panama',
'Papua New Guinea' => 'Papua New Guinea',
'Paraguay' => 'Paraguay',
'Peru' => 'Peru',
'Philippines' => 'Philippines',
'Pitcairn' => 'Pitcairn',
'Poland' => 'Poland',
'Portugal' => 'Portugal',
'Puerto Rico' => 'Puerto Rico',
'Qatar' => 'Qatar',
'Reunion' => 'Reunion',
'Romania' => 'Romania',
'Russia' => 'Russia',
'Russian Federation' => 'Russian Federation',
'Rwanda' => 'Rwanda',
'Saint Kitts and Nevis' => 'Saint Kitts and Nevis',
'Saint Lucia' => 'Saint Lucia',
'Saint Vincent and the Grenadines' => 'Saint Vincent and the Grenadines',
'Samoa (Independent)' => 'Samoa (Independent)',
'San Marino' => 'San Marino',
'Sao Tome and Principe' => 'Sao Tome and Principe',
'Saudi Arabia' => 'Saudi Arabia',
'Scotland' => 'Scotland',
'Senegal' => 'Senegal',
'Serbia and Montenegro' => 'Serbia and Montenegro',
'Seychelles' => 'Seychelles',
'Sierra Leone' => 'Sierra Leone',
'Singapore' => 'Singapore',
'Slovakia' => 'Slovakia',
'Slovenia' => 'Slovenia',
'Solomon Islands' => 'Solomon Islands',
'Somalia' => 'Somalia',
'South Africa' => 'South Africa',
'South Georgia and the South Sandwich Islands' => 'South Georgia and the South Sandwich Islands',
'South Korea' => 'South Korea',
'Spain' => 'Spain',
'Sri Lanka' => 'Sri Lanka',
'St. Helena' => 'St. Helena',
'St. Pierre and Miquelon' => 'St. Pierre and Miquelon',
'Suriname' => 'Suriname',
'Svalbard and Jan Mayen Islands' => 'Svalbard and Jan Mayen Islands',
'Swaziland' => 'Swaziland',
'Sweden' => 'Sweden',
'Switzerland' => 'Switzerland',
'Taiwan' => 'Taiwan',
'Tajikistan' => 'Tajikistan',
'Tanzania' => 'Tanzania',
'Thailand' => 'Thailand',
'Togo' => 'Togo',
'Tokelau' => 'Tokelau',
'Tonga' => 'Tonga',
'Trinidad' => 'Trinidad',
'Trinidad and Tobago' => 'Trinidad and Tobago',
'Tunisia' => 'Tunisia',
'Turkey' => 'Turkey',
'Turkmenistan' => 'Turkmenistan',
'Turks and Caicos Islands' => 'Turks and Caicos Islands',
'Tuvalu' => 'Tuvalu',
'Uganda' => 'Uganda',
'Ukraine' => 'Ukraine',
'United Arab Emirates' => 'United Arab Emirates',
'United Kingdom' => 'United Kingdom',
'United States' => 'United States',
'United States Minor Outlying Islands' => 'United States Minor Outlying Islands',
'Uruguay' => 'Uruguay',
'Uzbekistan' => 'Uzbekistan',
'Vanuatu' => 'Vanuatu',
'Vatican City State (Holy See)' => 'Vatican City State (Holy See)',
'Venezuela' => 'Venezuela',
'Viet Nam' => 'Viet Nam',
'Virgin Islands (British)' => 'Virgin Islands (British)',
'Virgin Islands (U.S.)' => 'Virgin Islands (U.S.)',
'Wales' => 'Wales',
'Wallis and Futuna Islands' => 'Wallis and Futuna Islands',
'Western Sahara' => 'Western Sahara',
'Yemen' => 'Yemen',
'Zambia' => 'Zambia',
'Zimbabwe' => 'Zimbabwe'
);
	$f->selectList(
		-name=>"country",
		-label=>$i18n->get("country"),
		-value=>[$session{form}{country}],
		-defaultValue=>[$u->profileField("homeCountry")],
		-options=>\%countries
		);
	$f->phone(
		-name=>"phone",
		-label=>$i18n->get("phone"),
		-value=>$session{form}{phone},
		-defaultValue=>$u->profileField("homePhone")
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
	%years = map {$_ => $_} 2004..2099;
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
	) if ($self->get('useCVV2'));

	return $f->printRowsOnly;	
}

#-------------------------------------------------------------------
sub configurationForm {
	my ($self, $f, $i18n);
	$self = shift;
 	$i18n = WebGUI::International->new('CommercePaymentITransact');

	$f = WebGUI::HTMLForm->new;
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
		-value	=> $i18n->get('extra info').'<br /><b>https://'.$session{config}{defaultSitename}.'/?op=confirmRecurringTransaction;gateway='.$self->namespace
		);
		
	return $self->SUPER::configurationForm($f->printRowsOnly);
}

#-------------------------------------------------------------------
sub confirmRecurringTransaction {
	#### !!!Site checken!!! ####
	my $self = shift;
	
	my $form = $session{form};
	my $transaction = WebGUI::Commerce::Transaction->getByGatewayId($session{form}{orig_xid}, $self->namespace);
	my $itemProperties = $transaction->getItems->[0];
	my $item = WebGUI::Commerce::Item->new($itemProperties->{itemId}, $itemProperties->{itemType});
	
	my $startEpoch = WebGUI::DateTime::setToEpoch(sprintf("%4d-%02d-%02d %02d:%02d:%02d", unpack('a4a2a2a2a2a2', $form->{start_date})));
	my $currentEpoch = WebGUI::DateTime::setToEpoch(sprintf("%4d-%02d-%02d %02d:%02d:%02d", unpack('a4a2a2a2a2a2', $form->{when})));
	
	WebGUI::SQL->write("delete from ITransact_recurringStatus where gatewayId=".quote($form->{orig_xid}));
	WebGUI::SQL->write("insert into ITransact_recurringStatus ".
		"(gatewayId, initDate, lastTransaction, status, errorMessage, recipe) values ".
		"(".quote($form->{orig_xid}).", $startEpoch, $currentEpoch, ".quote($form->{status}).", ".quote($form->{error_message}).
		", ".quote($form->{recipe_name}).")");
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
		
	$self = $class->SUPER::init('ITransact');

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

	my $transactionData = WebGUI::SQL->quickHashRef("select * from ITransact_recurringStatus where gatewayId=".quote($recurringId));
	unless ($transactionData->{recipe}) { # if for some reason there's no transaction data, we shouldn't calc anything
		WebGUI::ErrorHandler::error("For some reason recurring transaction $recurringId doesn't have any recurring status transaction data. This is most likely because you don't have the Recurring Postback URL set in your ITransact virtual terminal.");
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
	return WebGUI::International::get('module name', "CommercePaymentITransact");
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
		$self->{_recurring} = 0;
		$self->{_transactionParams} = {
			AMT		=> sprintf('%.2f', $normal->{amount}),
			DESCRIPTION	=> $normal->{description} || WebGUI::International::get('no description', "CommercePaymentITransact"),
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
		$initialAmount = (WebGUI::DateTime::getDaysInMonth(time) - (WebGUI::DateTime::localtime)[2])*$recurring->{amount}/WebGUI::DateTime::getDaysInMonth(time);
		$initialAmount = $recurring->{amount} if ($initialAmount < 1);
		$self->{_recurring} = 1;
		$self->{_transactionParams} = {
			START		=> $recurring->{start} || WebGUI::DateTime::epochToHuman(WebGUI::DateTime::addToDate(time, 0, 0, 1), '%m%d%y'),
			AMT		=> sprintf('%.2f', $recurring->{amount}),
			INITIALAMT	=> sprintf('%.2f', $initialAmount),
			TERM		=> $recurring->{term} || 9999,
			RECIPE		=> _resolveRecipe($recurring->{payPeriod}),
			DESCRIPTION	=> $recurring->{description} || WebGUI::International::get('no description', "CommercePaymentITransact"),
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
	
	return $self->{_errorMessage} if ($self->connectionError);
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
    <HomePage>".$session{setting}{companyURL}."</HomePage>";

	if ($self->{_recurring}) {
		$xml .=
"    <RecurringData>
      <RecurRecipe>$transactionData{RECIPE}</RecurRecipe>
      <RecurReps>$transactionData{TERM}</RecurReps>
      <RecurTotal>$transactionData{AMT}</RecurTotal>
      <RecurDesc>$transactionData{DESCRIPTION}</RecurDesc>
    </RecurringData>";
	};

	$xml .=
"    <EmailText>
      <EmailTextItem>".$self->get('emailMessage')."</EmailTextItem>
      <EmailTextItem>ID: $transactionData{ORGID}</EmailTextItem>
    </EmailText>\n";

	$items = WebGUI::Commerce::Transaction->new($transactionData{ORGID})->getItems;
	foreach (@{$items}) {
		$xml .= 
"    <OrderItems>
      <Item>
        <Description>".$_->{itemName}."</Description>
	<Cost>".$_->{amount}."</Cost>
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

	$i18n = WebGUI::International->new('CommercePaymentITransact');

	push (@error, $i18n->get('invalid firstName')) unless ($session{form}{firstName});
	push (@error, $i18n->get('invalid lastName')) unless ($session{form}{lastName});
	push (@error, $i18n->get('invalid address')) unless ($session{form}{address});
	push (@error, $i18n->get('invalid city')) unless ($session{form}{city});
	push (@error, $i18n->get('invalid zip')) if ($session{form}{zipcode} eq "" && $session{form}{country} eq "United States");
	push (@error, $i18n->get('invalid email')) unless ($session{form}{email});
	
	push (@error, $i18n->get('invalid card number')) unless ($session{form}{cardNumber} =~ /^\d+$/);	
	push (@error, $i18n->get('invalid cvv2')) if ($session{form}{cvv2} !~ /^\d+$/ && $self->get('useCVV2'));

	($currentYear, $currentMonth) = WebGUI::DateTime::localtime;

	# Check if expDate and expYear have sane values
	unless (($session{form}{expMonth} =~ /^(0[1-9]|1[0-2])$/) && ($session{form}{expYear} =~ /^\d\d\d\d$/)) {
		push (@error, $i18n->get('invalid expiration date'));
	} elsif (($session{form}{expYear} < $currentYear) || 
		(($session{form}{expYear} == $currentYear) && ($session{form}{expMonth} < $currentMonth))) {
		push (@error, $i18n->get('invalid expiration date'));
	}

	unless (@error) {
		$self->{_cardData} = {
			ACCT		=> $session{form}{cardNumber},
			EXPMONTH	=> $session{form}{expMonth},
			EXPYEAR		=> $session{form}{expYear},
			CVV2		=> $session{form}{cvv2},
		};	
		
		$self->{_userData} = {
			STREET		=> $session{form}{address},
			ZIP		=> $session{form}{zipcode},
			CITY		=> $session{form}{city},
			FIRSTNAME	=> $session{form}{firstName},
			LASTNAME	=> $session{form}{lastName},
			EMAIL		=> $session{form}{email},
			STATE		=> $session{form}{state},
			COUNTRY		=> $session{form}{country},
			PHONE		=> $session{form}{phone},
		};

		return 0;
	}
			
	return \@error;
}

1;

