package WebGUI::i18n::English::Tax;

use strict;

our $I18N = {

	'country' => {
		message => q|Country|,
		lastUpdated => 1205120607,
		context => q|The name of a country, such as Portugal or Canada.|,
	},

	'country help' => {
		message => q|The name of the country that the tax applies to.|,
		lastUpdated => 1205120607,
		context => q|The name of a country, such as Portugal or Canada.|,
	},

	'state' => {
		message => q|State|,
		lastUpdated => 1205120615,
		context => q|A political subdivision of a country, such as California.|,
	},

	'state help' => {
		message => q|The name of the state or province that the tax applies to.|,
		lastUpdated => 1205120615,
		context => q|A political subdivision of a country, such as California.|,
	},

	'city' => {
		message => q|City|,
		lastUpdated => 1205120661,
	},

	'city help' => {
		message => q|The name of the city that the tax applies to.|,
		lastUpdated => 1205120661,
	},

	'code' => {
		message => q|Code|,
		lastUpdated => 1205120660,
		context => q|A postal code, or zip code.|,
	},

	'code help' => {
		message => q|The postal or zip code that the tax applies to.|,
		lastUpdated => 1205120660,
		context => q|A postal code, or zip code.|,
	},

	'tax rate' => {
		message => q|Tax Rate|,
		lastUpdated => 1206302052,
		context => q|The amount that a person is charged to buy something, a percentage of the price.|,
	},

	'tax rate help' => {
		message => q|Enter the tax as a percentage.  For 5%, enter 5|,
		lastUpdated => 1206302052,
		context => q|The amount that a person is charged to buy something, a percentage of the price.|,
	},

	'delete' => {
		message => q|delete|,
		lastUpdated => 1206385749,
		context => q|To remove one tax entry from the tax tables.|,
	},

	'add a tax' => {
		message => q|Add new tax information|,
		lastUpdated => 1206395083,
	},

	'override tax rate' => {
		message => q|Override tax rate?|,
		lastUpdated => 0,
		context => q|A yes/no field asking whether to override tax rate.|
	},

	'override tax rate help' => {
		message => q|Would you like to override the default tax rate for this item? Usually used in locales that have special or no tax on life essential items like food and clothing.|,
		lastUpdated => 0,
		context => q|help for override tax rate field|
	},

	'tax rate override' => {
		message => q|Tax Rate Override|,
		lastUpdated => 0,
		context => q|a field containing the percentage to use to calculate tax for this item|
	},

	'tax rate override help' => {
		message => q|What is the new percentage that should be used to calculate tax on this item?|,
		lastUpdated => 0,
		context => q|help for tax rate override field|
	},

	'Switch tax plugin' => {
		message => q|Switch tax plugin|,
		lastUpdated => 0,
		context => q||,
	},

	'Switch' => {
		message => q|Switch|,
		lastUpdated => 0,
		context => q|Switch, as in to exchange one for another.|,
	},

	'Active tax plugin' => {
		message => q|Active tax plugin|,
		lastUpdated => 0,
		context => q||,
	},

	'Stern tax warning' => {
		message => q|Changing the active tax plugin will change the way tax is calulated on <b>all</b> products you sell. Are you really sure you want to switch?|,
		lastUpdated => 0,
		context => q||,
	},

	'Proceed' => {
		message => q|Proceed|,
		lastUpdated => 0,
		context => q|to continue|,
	},

};

1;
