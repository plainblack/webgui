package WebGUI::Shop::PayDriver::PayPal;

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

## this holds some shared functionality, and MUST be overridden for a full payment driver
use strict;
use base qw/WebGUI::Shop::PayDriver/;
use warnings;

=head1 NAME

WebGUI::Shop::PayDriver::PayPal

=head1 DESCRIPTION

Super class for PayPal payment drivers

=head1 METHODS

These methods are available from this class:

=cut

=head2 getPaymentCurrencies

Returns a hash reference of currency codes and their full names.

=cut

sub getPaymentCurrencies {
    return {
        "AUD" => "Australian Dollar",
        "CAD" => "Canadian Dollar",
        "CHF" => "Swiss Franc",
        "CZK" => "Czech Koruna",
        "DKK" => "Danish Krone",
        "EUR" => "Euro",
        "GBP" => "Pound Sterling",
        "HKD" => "Hong Kong Dollar",
        "HUF" => "Hungarian Forint",
        "JPY" => "Japanese Yen",
        "NOK" => "Norwegian Krone",
        "NZD" => "New Zealand Dollar",
        "PLN" => "Polish Zloty",
        "SEK" => "Swedish Krona",
        "SGD" => "Singapore Dollar",
        "USD" => "U.S. Dollar"
    };
}

=head2 getCardTypes

Returns a hash of credit card types

=cut

sub getCardTypes {
    return (
        'Visa'       => 'Visa',
        'MasterCard' => 'MasterCard',
        'Discover'   => 'Discover',
        'Amex'       => 'Amex'
    );
}

my %paypalCountries = (
    "AFGHANISTAN"                                  => "AF",
    "ÅLAND ISLANDS"                               => "AX",
    "ALBANIA"                                      => "AL",
    "ALGERIA"                                      => "DZ",
    "AMERICAN SAMOA"                               => "AS",
    "ANDORRA"                                      => "AD",
    "ANGOLA"                                       => "AO",
    "ANGUILLA"                                     => "AI",
    "ANTARCTICA"                                   => "AQ",
    "ANTIGUA AND BAR­BUDA"                        => "AG",
    "ARGENTINA"                                    => "AR",
    "ARMENIA"                                      => "AM",
    "ARUBA"                                        => "AW",
    "AUSTRALIA"                                    => "AU",
    "AUSTRIA"                                      => "AT",
    "AZERBAIJAN"                                   => "AZ",
    "BAHAMAS"                                      => "BS",
    "BAHRAIN"                                      => "BH",
    "BANGLADESH"                                   => "BD",
    "BARBADOS"                                     => "BB",
    "BELARUS"                                      => "BY",
    "BELGIUM"                                      => "BE",
    "BELIZE"                                       => "BZ",
    "BENIN"                                        => "BJ",
    "BERMUDA"                                      => "BM",
    "BHUTAN"                                       => "BT",
    "BOLIVIA"                                      => "BO",
    "BOSNIA AND HERZE­GOVINA"                     => "BA",
    "BOTSWANA"                                     => "BW",
    "BOUVET ISLAND"                                => "BV",
    "BRAZIL"                                       => "BR",
    "BRITISH INDIAN OCEAN TERRITORY"               => "IO",
    "BRUNEI DARUSSALAM"                            => "BN",
    "BULGARIA"                                     => "BG",
    "BURKINA FASO"                                 => "BF",
    "BURUNDI"                                      => "BI",
    "CAMBODIA"                                     => "KH",
    "CAMEROON"                                     => "CM",
    "CANADA"                                       => "CA",
    "CAPE VERDE"                                   => "CV",
    "CAYMAN ISLANDS"                               => "KY",
    "CENTRAL AFRICAN REPUBLIC"                     => "CF",
    "CHAD"                                         => "TD",
    "CHILE"                                        => "CL",
    "CHINA"                                        => "CN",
    "CHRISTMAS ISLAND"                             => "CX",
    "COCOS (KEELING) ISLANDS"                      => "CC",
    "COLOMBIA"                                     => "CO",
    "COMOROS"                                      => "KM",
    "CONGO"                                        => "CG",
    "CONGO, THE DEMO­CRATIC REPUBLIC OF THE"      => "CD",
    "COOK ISLANDS"                                 => "CK",
    "COSTA RICA"                                   => "CR",
    "COTE D'IVOIRE"                                => "CI",
    "CROATIA"                                      => "HR",
    "CUBA"                                         => "CU",
    "CYPRUS"                                       => "CY",
    "CZECH REPUBLIC"                               => "CZ",
    "DENMARK"                                      => "DK",
    "DJIBOUTI"                                     => "DJ",
    "DOMINICA"                                     => "DM",
    "DOMINICAN REPUBLIC"                           => "DO",
    "ECUADOR"                                      => "EC",
    "EGYPT"                                        => "EG",
    "EL SALVADOR"                                  => "SV",
    "EQUATORIAL GUINEA"                            => "GQ",
    "ERITREA"                                      => "ER",
    "ESTONIA"                                      => "EE",
    "ETHIOPIA"                                     => "ET",
    "FALKLAND ISLANDS (MALVINAS)"                  => "FK",
    "FAROE ISLANDS"                                => "FO",
    "FIJI"                                         => "FJ",
    "FINLAND"                                      => "FI",
    "FRANCE"                                       => "FR",
    "FRENCH GUIANA"                                => "GF",
    "FRENCH POLYNESIA"                             => "PF",
    "FRENCH SOUTHERN TERRITORIES"                  => "TF",
    "GABON"                                        => "GA",
    "GAMBIA"                                       => "GM",
    "GEORGIA"                                      => "GE",
    "GERMANY"                                      => "DE",
    "GHANA"                                        => "GH",
    "GIBRALTAR"                                    => "GI",
    "GREECE"                                       => "GR",
    "GREENLAND"                                    => "GL",
    "GRENADA"                                      => "GD",
    "GUADELOUPE"                                   => "GP",
    "GUAM"                                         => "GU",
    "GUATEMALA"                                    => "GT",
    "GUERNSEY"                                     => "GG",
    "GUINEA"                                       => "GN",
    "GUINEA-BISSAU"                                => "GW",
    "GUYANA"                                       => "GY",
    "HAITI"                                        => "HT",
    "HEARD ISLAND AND MCDONALD ISLANDS"            => "HM",
    "HOLY SEE (VATICAN CITY STATE)"                => "VA",
    "HONDURAS"                                     => "HN",
    "HONG KONG"                                    => "HK",
    "HUNGARY"                                      => "HU",
    "ICELAND"                                      => "IS",
    "INDIA"                                        => "IN",
    "INDONESIA"                                    => "ID",
    "IRAN, ISLAMIC REPUB­LIC OF"                  => "IR",
    "IRAQ"                                         => "IQ",
    "IRELAND"                                      => "IE",
    "ISLE OF MAN"                                  => "IM",
    "ISRAEL"                                       => "IL",
    "ITALY"                                        => "IT",
    "JAMAICA"                                      => "JM",
    "JAPAN"                                        => "JP",
    "JERSEY"                                       => "JE",
    "JORDAN"                                       => "JO",
    "KAZAKHSTAN"                                   => "KZ",
    "KENYA"                                        => "KE",
    "KIRIBATI"                                     => "KI",
    "KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF"       => "KP",
    "KOREA, REPUBLIC OF"                           => "KR",
    "KUWAIT"                                       => "KW",
    "KYRGYZSTAN"                                   => "KG",
    "LAO PEOPLE'S DEMO­CRATIC REPUBLIC"           => "LA",
    "LATVIA"                                       => "LV",
    "LEBANON"                                      => "LB",
    "LESOTHO"                                      => "LS",
    "LIBERIA"                                      => "LR",
    "LIBYAN ARAB JAMA­HIRIYA"                     => "LY",
    "LIECHTENSTEIN"                                => "LI",
    "LITHUANIA"                                    => "LT",
    "LUXEMBOURG"                                   => "LU",
    "MACAO"                                        => "MO",
    "MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF"   => "MK",
    "MADAGASCAR"                                   => "MG",
    "MALAWI"                                       => "MW",
    "MALAYSIA"                                     => "MY",
    "MALDIVES"                                     => "MV",
    "MALI"                                         => "ML",
    "MALTA"                                        => "MT",
    "MARSHALL ISLANDS"                             => "MH",
    "MARTINIQUE"                                   => "MQ",
    "MAURITANIA"                                   => "MR",
    "MAURITIUS"                                    => "MU",
    "MAYOTTE"                                      => "YT",
    "MEXICO"                                       => "MX",
    "MICRONESIA, FEDER­ATED STATES OF"            => "FM",
    "MOLDOVA, REPUBLIC OF"                         => "MD",
    "MONACO"                                       => "MC",
    "MONGOLIA"                                     => "MN",
    "MONTSERRAT"                                   => "MS",
    "MOROCCO"                                      => "MA",
    "MOZAMBIQUE"                                   => "MZ",
    "MYANMAR"                                      => "MM",
    "NAMIBIA"                                      => "NA",
    "NAURU"                                        => "NR",
    "NEPAL"                                        => "NP",
    "NETHERLANDS"                                  => "NL",
    "NETHERLANDS ANTI­LLES"                       => "AN",
    "NEW CALEDONIA"                                => "NC",
    "NEW ZEALAND"                                  => "NZ",
    "NICARAGUA"                                    => "NI",
    "NIGER"                                        => "NE",
    "NIGERIA"                                      => "NG",
    "NIUE"                                         => "NU",
    "NORFOLK ISLAND"                               => "NF",
    "NORTHERN MARIANA ISLANDS"                     => "MP",
    "NORWAY"                                       => "NO",
    "OMAN"                                         => "OM",
    "PAKISTAN"                                     => "PK",
    "PALAU"                                        => "PW",
    "PALESTINIAN TERRI­TORY, OCCUPIED"            => "PS",
    "PANAMA"                                       => "PA",
    "PAPUA NEW GUINEA"                             => "PG",
    "PARAGUAY"                                     => "PY",
    "PERU"                                         => "PE",
    "PHILIPPINES"                                  => "PH",
    "PITCAIRN"                                     => "PN",
    "POLAND"                                       => "PL",
    "PORTUGAL"                                     => "PT",
    "PUERTO RICO"                                  => "PR",
    "QATAR"                                        => "QA",
    "REUNION"                                      => "RE",
    "ROMANIA"                                      => "RO",
    "RUSSIAN FEDERATION"                           => "RU",
    "RWANDA"                                       => "RW",
    "SAINT HELENA"                                 => "SH",
    "SAINT KITTS AND NEVIS"                        => "KN",
    "SAINT LUCIA"                                  => "LC",
    "SAINT PIERRE AND MIQUELON"                    => "PM",
    "SAINT VINCENT AND THE GRENADINES"             => "VC",
    "SAMOA"                                        => "WS",
    "SAN MARINO"                                   => "SM",
    "SAO TOME AND PRINC­IPE"                      => "ST",
    "SAUDI ARABIA"                                 => "SA",
    "SENEGAL"                                      => "SN",
    "SERBIA AND MON­TENEGRO"                      => "CS",
    "SEYCHELLES"                                   => "SC",
    "SIERRA LEONE"                                 => "SL",
    "SINGAPORE"                                    => "SG",
    "SLOVAKIA"                                     => "SK",
    "SLOVENIA"                                     => "SI",
    "SOLOMON ISLANDS"                              => "SB",
    "SOMALIA"                                      => "SO",
    "SOUTH AFRICA"                                 => "ZA",
    "SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS" => "GS",
    "SPAIN"                                        => "ES",
    "SRI LANKA"                                    => "LK",
    "SUDAN"                                        => "SD",
    "SURINAME"                                     => "SR",
    "SVALBARD AND JAN MAYEN"                       => "SJ",
    "SWAZILAND"                                    => "SZ",
    "SWEDEN"                                       => "SE",
    "SWITZERLAND"                                  => "CH",
    "SYRIAN ARAB REPUB­LIC"                       => "SY",
    "TAIWAN, PROVINCE OF CHINA"                    => "TW",
    "TAJIKISTAN"                                   => "TJ",
    "TANZANIA, UNITED REPUBLIC OF"                 => "TZ",
    "THAILAND"                                     => "TH",
    "TIMOR-LESTE"                                  => "TL",
    "TOGO"                                         => "TG",
    "TOKELAU"                                      => "TK",
    "TONGA"                                        => "TO",
    "TRINIDAD AND TOBAGO"                          => "TT",
    "TUNISIA"                                      => "TN",
    "TURKEY"                                       => "TR",
    "TURKMENISTAN"                                 => "TM",
    "TURKS AND CAICOS ISLANDS"                     => "TC",
    "TUVALU"                                       => "TV",
    "UGANDA"                                       => "UG",
    "UKRAINE"                                      => "UA",
    "UNITED ARAB EMIR­ATES"                       => "AE",
    "UNITED KINGDOM"                               => "GB",
    "UNITED STATES"                                => "US",
    "UNITED STATES MINOR OUTLYING ISLANDS"         => "UM",
    "URUGUAY"                                      => "UY",
    "UZBEKISTAN"                                   => "UZ",
    "VANUATU"                                      => "VU",
    "VENEZUELA"                                    => "VE",
    "VIET NAM"                                     => "VN",
    "VIRGIN ISLANDS, BRIT­ISH"                    => "VG",
    "VIRGIN ISLANDS, U.S."                         => "VI",
    "WALLIS AND FUTUNA"                            => "WF",
    "WESTERN SAHARA"                               => "EH",
    "YEMEN"                                        => "YE",
    "ZAMBIA"                                       => "ZM",
    "ZIMBABWE"                                     => "ZW"
);

=head2 getPaypalCountry ( $country )

Accepts a country name and returns the country code for it.

=head3 $country

The country to find the code for.

=cut

sub getPaypalCountry {
    my $self        = shift;
    my $longCountry = shift;

    my $retcode = $paypalCountries{ uc $longCountry };
    return $retcode;
}

1;

