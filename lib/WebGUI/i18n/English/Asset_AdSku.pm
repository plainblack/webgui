package WebGUI::i18n::English::Asset_AdSku; 
use strict;

our $I18N = { 
    'assetName' => {
        message => q|Ad Sales|,
        lastUpdated => 0,
        context => q|The name of the Ad Sales asset|,
    },


	'property purchase template' => {
		message => q|purchase template|,
		lastUpdated => 0,
		context => q|the name of the template to use for purchasing ad space|
	},

	'property purchase template help' => {
		message => q|select a template to use for purchasing ad space|,
		lastUpdated => 0,
		context => q|select a template to use for purchasing ad space|
	},

	'property manage template' => {
		message => q|manage template|,
		lastUpdated => 0,
		context => q|the name of the template to use for managing ad space|
	},

	'property manage template help' => {
		message => q|select a template to use for managing ad space|,
		lastUpdated => 0,
		context => q|select a template to use for managing ad space|
	},

	'property ad space' => {
		message => q|ad space|,
		lastUpdated => 0,
		context => q|the ad space being sold here|
	},

	'property ad Space help' => {
		message => q|select the ad space being sold by this SKU|,
		lastUpdated => 0,
		context => q|select the ad space being sold by this SKU|
	},

	'property priority' => {
		message => q|priority|,
		lastUpdated => 0,
		context => q|the priority of the ads sold by this SKU|
	},

	'property priority help' => {
		message => q|indicate the priority of ads sold by this SKU.  you can use multiple SKU's to sell the same ad space at different rates by setting different priorities for each SKU|,
		lastUpdated => 0,
		context => q|help text for the priority field on the AdSku Edit page|
	},

	'property price per click' => {
		message => q|price per click|,
		lastUpdated => 0,
		context => q|the price charged per click|
	},

	'property price per click help' => {
		message => q|indicate how much to charge for each click purchased|,
		lastUpdated => 1165511641,
		context => q|help for the price per click field|
	},

	'property price per impression' => {
		message => q|price per impression|,
		lastUpdated => 0,
		context => q|the price charged for each impression of this ad|
	},

	'property price per impression help' => {
		message => q|indicate how much to purchase for each impression purchased|,
		lastUpdated => 0,
		context => q|help text fot the price per impression field|
	},

	'property click discounts' => {
		message => q|click discounts|,
		lastUpdated => 0,
		context => q|the discounts offered based on number of clicks|
	},

	'property click discounts help' => {
		message => q|enter discounts one per line at the start of the line.  extra text is ignored so you can put comments.  each discount consists of two numbers seperated by '@' with no spaces.  the first number is the percent(no decimal point) the second number is the number of items purchased|,
		lastUpdated => 0,
		context => q|help text for the click discounts field|
	},

	'property impression discounts' => {
		message => q|impression discounts|,
		lastUpdated => 0,
		context => q|the discounts offered based on number of impressions purchased|
	},

	'property impression discounts help' => {
		message => q|enter discounts one per line at the start of the line.  extra text is ignored so you can put comments.  each discount consists of two numbers seperated by '@' with no spaces.  the first number is the percent(no decimal point) the second number is the number of items purchased|,
		lastUpdated => 0,
		context => q|help text for the impresison discounts field|
	},

	'property adsku karma' => {
		message => q|karma|,
		lastUpdated => 0,
		context => q|the karm field name|
	},

	'property adsku karma description' => {
		message => q|how much karm dos this offer|,
		lastUpdated => 0,
		context => q|description for the karma field|
	},

	'form purchase per click' => {
		message => q|@ %f per click|,
		lastUpdated => 0,
		context => q|%f is the price charged for each click on the ad|
	},

	'form purchase per impression' => {
		message => q|@ %f per impression|,
		lastUpdated => 0,
		context => q|%f is the price charged for each impression of the ad|
	},

	'form manage title' => {
		message => q|Manage My Ads|,
		lastUpdated => 0,
		context => q|text for the title of the form where the user can manage previously purchased advertisements|
	},

	'form manage link' => {
		message => q|Manage My Ads|,
		lastUpdated => 0,
		context => q|text for a link to the form where the user can manage previously purchased advertisements|
	},

	'form purchase link' => {
		message => q|Purchase Ads|,
		lastUpdated => 0,
		context => q|text for a link to the form where the user can purchase advertisements|
	},

	'form manage table header title' => {
		message => q|Title|,
		lastUpdated => 0,
		context => q|header for the adspace manage form: the title field|
	},

	'form manage table header clicks' => {
		message => q|Clicks|,
		lastUpdated => 0,
		context => q|header for the adspace manage form: the clicks field|
	},

	'form manage table header impressions' => {
		message => q|Impressions|,
		lastUpdated => 0,
		context => q|header for the adspace manage form: the impressions field|
	},

	'form manage table header renew' => {
		message => q|Renew|,
		lastUpdated => 0,
		context => q|header for the adspace manage form: the renew field|
	},

	'form manage table value deleted' => {
		message => q|Deleted|,
		lastUpdated => 0,
		context => q|contents for the renew field on the manage ads table: indicates a deleted item|
	},

	'form manage table value renew' => {
		message => q|Renew|,
		lastUpdated => 0,
		context => q|contents for the renew field on the manage ads table: indicates a renewable item|
	},

	'form purchase button' => {
		message => q|Add To Cart|,
		lastUpdated => 0,
		context => q|add the described item to the shopping cart|
	},

	'form purchase ad title' => {
		message => q|Ad Title|,
		lastUpdated => 0,
		context => q|the title chosen by the buyer for the advertisement|
	},

	'form purchase ad link' => {
		message => q|Ad Link|,
		lastUpdated => 0,
		context => q|the link the advertisement leads to|
	},

	'form purchase ad image' => {
		message => q|Image|,
		lastUpdated => 0,
		context => q|the image to be displayed in the ad|
	},

	'form purchase number of clicks' => {
		message => q|Number of Clicks|,
		lastUpdated => 0,
		context => q|the number of clicks the buyer wishes to purchase|
	},

	'form purchase number of impressions' => {
		message => q|Number of Impressions|,
		lastUpdated => 0,
		context => q|the number of impressions the user wishes to purchase|
	},

#	'TODO' => {
#		message => q|TODO|,
#		lastUpdated => 0,
#		context => q|TODO|
#	},

};

1;
