package WebGUI::Form::Country;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::SelectBox';
use Tie::IxHash;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Country

=head1 DESCRIPTION

Creates a country chooser control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectBox.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

The identifier for this field. Defaults to "country".

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get('country')
			},
		label=>{
			defaultValue=>$i18n->get('country')
			},
		name=>{
			defaultValue=>"country"
			},
		defaultValue=>{
			defaultValue=>"United States"
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a country picker control.

=cut

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

sub toHtml {
	my $self = shift;
	$self->set("options", \%countries);
	return $self->SUPER::toHtml();
}

1;
