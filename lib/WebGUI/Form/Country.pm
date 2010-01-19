package WebGUI::Form::Country;

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

=head2 areOptionsSettable ( )

Returns 0.

=cut

sub areOptionsSettable {
    return 0;
}

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

=head2 getCountries

Returns the list of Countries

=cut

sub getCountries {
    return (
        'Afghanistan',                           'Albania',
        'Algeria',                               'American Samoa',
        'Andorra',                               'Anguilla',
        'Antarctica',                            'Antigua And Barbuda',
        'Argentina',                             'Armenia',
        'Aruba',                                 'Australia',
        'Austria',                               'Azerbaijan',
        'Bahamas',                               'Bahrain',
        'Bangladesh',                            'Barbados',
        'Belarus',                               'Belgium',
        'Belize',                                'Benin',
        'Bermuda',                               'Bhutan',
        'Bolivia',                               'Bosnia and Herzegovina',
        'Botswana',                              'Bouvet Island',
        'Brazil',                                'British Indian Ocean Territory',
        'Brunei Darussalam',                     'Bulgaria',
        'Burkina Faso',                          'Burundi',
        'Cambodia',                              'Cameroon',
        'Canada',                                'Cape Verde',
        'Cayman Islands',                        'Central African Republic',
        'Chad',                                  'Chile',
        'China',                                 'Christmas Island',
        'Christmas Island (Kiribati)',           'Cocos (Keeling) Islands',
        'Colombia',                              'Comoros',
        'Congo',                                 'Congo, the Democratic Republic of the',
        'Cook Islands',                          'Costa Rica',
        'Cote d\'Ivoire',                        'Croatia',
        'Cyprus',                                'Czech Republic',
        'Denmark',                               'Djibouti',
        'Dominica',                              'Dominican Republic',
        'East Timor',                            'Ecuador',
        'Egypt',                                 'El Salvador',
        'England',                               'Equatorial Guinea',
        'Eritrea',                               'Estonia',
        'Ethiopia',                              'Falkland Islands',
        'Faroe Islands',                         'Fiji',
        'Finland',                               'France',
        'French Guiana',                         'French Polynesia',
        'French Southern Territories',           'Gabon',
        'Gambia',                                'Georgia',
        'Germany',                               'Ghana',
        'Gibraltar',                             'Great Britain',
        'Greece',                                'Greenland',
        'Grenada',                               'Guadeloupe',
        'Guam',                                  'Guatemala',
        'Guinea',                                'Guinea-Bissau',
        'Guyana',                                'Haiti',
        'Heard and Mc Donald Islands',           'Honduras',
        'Hong Kong',                             'Hungary',
        'Iceland',                               'India',
        'Indonesia',                             'Ireland',
        'Israel',                                'Italy',
        'Jamaica',                               'Japan',
        'Jordan',                                'Kazakhstan',
        'Kenya',                                 'Kiribati',
        'Korea (South)',                         'Korea, Republic of',
        'Kuwait',                                'Kyrgyzstan',
        'Lao People\'s Democratic Republic',     'Latvia',
        'Lebanon',                               'Lesotho',
        'Liberia',                               'Libya',
        'Liechtenstein',                         'Lithuania',
        'Luxembourg',                            'Macau',
        'Macedonia',                             'Madagascar',
        'Malawi',                                'Malaysia',
        'Maldives',                              'Mali',
        'Malta',                                 'Marshall Islands',
        'Martinique',                            'Mauritania',
        'Mauritius',                             'Mayotte',
        'Mexico',                                'Micronesia, Federated States of',
        'Moldova, Republic of',                  'Monaco',
        'Mongolia',                              'Montenegro',
        'Montserrat',                            'Morocco',
        'Mozambique',                            'Myanmar',
        'Namibia',                               'Nauru',
        'Nepal',                                 'Netherlands',
        'Netherlands Antilles',                  'New Caledonia',
        'New Zealand',                           'Nicaragua',
        'Niger',                                 'Nigeria',
        'Niue',                                  'Norfolk Island',
        'Northern Ireland',                      'Northern Mariana Islands',
        'Norway',                                'Oman',
        'Pakistan',                              'Palau',
        'Panama',                                'Papua New Guinea',
        'Paraguay',                              'Peru',
        'Philippines',                           'Pitcairn',
        'Poland',                                'Portugal',
        'Puerto Rico',                           'Qatar',
        'Reunion',                               'Romania',
        'Russia',                                'Russian Federation',
        'Rwanda',                                'Saint Kitts and Nevis',
        'Saint Lucia',                           'Saint Vincent and the Grenadines',
        'Samoa (Independent)',                   'San Marino',
        'Sao Tome and Principe',                 'Saudi Arabia',
        'Scotland',                              'Senegal',
        'Serbia',                                'Seychelles',
        'Sierra Leone',                          'Singapore',
        'Slovakia',                              'Slovenia',
        'Solomon Islands',                       'Somalia',
        'South Africa',                          'South Georgia and the South Sandwich Islands',
        'South Korea',                           'Spain',
        'Sri Lanka',                             'St. Helena',
        'St. Pierre and Miquelon',               'Suriname',
        'Svalbard and Jan Mayen Islands',        'Swaziland',
        'Sweden',                                'Switzerland',
        'Taiwan',                                'Tajikistan',
        'Tanzania',                              'Thailand',
        'Togo',                                  'Tokelau',
        'Tonga',                                 'Trinidad',
        'Trinidad and Tobago',                   'Tunisia',
        'Turkey',                                'Turkmenistan',
        'Turks and Caicos Islands',              'Tuvalu',
        'Uganda',                                'Ukraine',
        'United Arab Emirates',                  'United Kingdom',
        'United States',                         'United States Minor Outlying Islands',
        'Uruguay',                               'Uzbekistan',
        'Vanuatu',                               'Vatican City State (Holy See)',
        'Venezuela',                             'Viet Nam',
        'Virgin Islands (British)',              'Virgin Islands (U.S.)',
        'Wales',                                 'Wallis and Futuna Islands',
        'Western Sahara',                        'Yemen',
        'Zambia',                                'Zimbabwe'
    );
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('country');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a country picker control.

=cut

sub toHtml {
	my $self = shift;

	my %countries;
	tie %countries, 'Tie::IxHash';
	%countries = map {$_ => $_} getCountries();
	$self->set("options", \%countries);
	return $self->SUPER::toHtml();
}

1;
