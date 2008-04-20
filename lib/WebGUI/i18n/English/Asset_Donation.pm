package WebGUI::i18n::English::Asset_Donation;

use strict;

our $I18N = { 
	'donate button' => {
		message => q|Add Donation To Cart|,
		lastUpdated => 0,
		context => q|the text that will appear on the donation button|
	},

	'default thank you message' => {
		message => q|Thank you for your kind donation.|,
		lastUpdated => 0,
		context => q|the default message that will go in the thank you message field|
	},

	'thank you message' => {
		message => q|Thank You Message|,
		lastUpdated => 0,
		context => q|the label for the field where you type in a message thanking the user for their donation|
	},

	'thank you message help' => {
		message => q|Write a thank you message to your user for donating. Be sincere. Remember they've just put the donation in the cart at this point, they haven't checked out yet.|,
		lastUpdated => 0,
		context => q|help for default price field|
	},

	'template' => {
		message => q|Template|,
		lastUpdated => 0,
		context => q|the label for the field where you select the template for this asset|
	},

	'template help' => {
		message => q|Choose a template that should be used to display the donation.|,
		lastUpdated => 0,
		context => q|help for default price field|
	},

	'default price' => {
		message => q|Default Price|,
		lastUpdated => 0,
		context => q|the label for the field that asks what the default donation amount should be.|
	},

	'default price help' => {
		message => q|How much money are you asking for per user? Note that they can type in any amount they wish, this is just a suggestion.|,
		lastUpdated => 0,
		context => q|help for default price field|
	},

	'assetName' => {
		message => q|Donation|,
		lastUpdated => 0,
        context => "The name of this asset. Used to contribute money."
	},

};

1;
