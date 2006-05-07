package WebGUI::Commerce::Payment::Cash;

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
	$f->selectBox(
		-name=>"country",
		-label=>$i18n->get("country"),
		-value=>($self->session->form->process("country",'selectBox') || $u->profileField("homeCountry")),
		-options=>\%countries
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
		-value 	=> $self->get('completeTransaction') || 1,
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
	my ($self) = shift;
	my $i18n = WebGUI::International->new($self->session, "CommercePaymentCash");
	return $i18n->get('module name');
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

