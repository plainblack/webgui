package WebGUI::i18n::English::Asset_AdSku; 
use strict;

our $I18N = { 
    'assetName' => {
        message => q|Ad Sales|,
        lastUpdated => 0,
        context => q|The name of the Ad Sales asset|,
    },


	'property purchase template' => {
		message => q|Purchase Template|,
		lastUpdated => 0,
		context => q|The name of the template to use for purchasing ad space.|
	},

	'property purchase template help' => {
		message => q|Select a template to use for purchasing ad space.|,
		lastUpdated => 0,
		context => q|Select a template to use for purchasing ad space.|
	},

	'property manage template' => {
		message => q|Manage Template|,
		lastUpdated => 0,
		context => q|The name of the template to use for managing ad space.|
	},

	'property manage template help' => {
		message => q|Select a template to use for managing ad space.|,
		lastUpdated => 0,
		context => q|Select a template to use for managing ad space.|
	},

	'property ad space' => {
		message => q|Ad Space|,
		lastUpdated => 0,
		context => q|The ad space being sold here.|
	},

	'property ad Space help' => {
		message => q|Select the ad space being sold by this SKU.|,
		lastUpdated => 0,
		context => q|Select the ad space being sold by this SKU.|
	},

	'property priority' => {
		message => q|Priority|,
		lastUpdated => 0,
		context => q|The priority of the ads sold by this SKU.|
	},

	'property priority help' => {
		message => q|Indicate the priority of ads sold by this SKU.  You can use multiple SKU's to sell the same ad space at different rates by setting different priorities for each SKU.|,
		lastUpdated => 0,
		context => q|Help text for the priority field on the AdSku Edit page.|
	},

	'property price per click' => {
		message => q|Price Per Click|,
		lastUpdated => 0,
		context => q|The price charged per click.|
	},

	'property price per click help' => {
		message => q|Indicate how much to charge for each click purchased.|,
		lastUpdated => 1165511641,
		context => q|Help for the price per click field.|
	},

	'property price per impression' => {
		message => q|Price Per Impression|,
		lastUpdated => 0,
		context => q|The price charged for each impression of this ad.|
	},

	'property price per impression help' => {
		message => q|Indicate how much to charge for each impression purchased.|,
		lastUpdated => 0,
		context => q|Help text for the price per impression field.|
	},

	'property click discounts' => {
		message => q|Click Discounts|,
		lastUpdated => 0,
		context => q|The discounts offered based on number of clicks.|
	},

	'property click discounts help' => {
		message => q|Enter discounts one per line at the start of the line.  Extra text is ignored so you can add comments to the discounts.  Each discount consists of two numbers separated by '@' with no spaces.  The first number is the percent discount(no decimal point) the second number is the number of items purchased.  So 5@1000 indicates a 5% discount for 1000 or more clicks purchased.|,
		lastUpdated => 1251410363,
		context => q|Help text for the click discounts field.|
	},

	'property impression discounts' => {
		message => q|Impression Discounts|,
		lastUpdated => 0,
		context => q|The discounts offered based on number of impressions purchased.|
	},

	'property impression discounts help' => {
		message => q|Enter discounts one per line at the start of the line.  Extra text is ignored so you can add comments to the discounts.  Each discount consists of two numbers separated by '@' with no spaces.  The first number is the percent discount(no decimal point) the second number is the number of items purchased. So 5@1000 indicates a 5% discount for 1000 or more impressions purchased.|,
		lastUpdated => 1251410361,
		context => q|Help text for the impression discounts field.|
	},

	'property adsku karma' => {
		message => q|karma|,
		lastUpdated => 0,
		context => q|The karm field name.|
	},

	'property adsku karma description' => {
		message => q|how much karma does this offer|,
		lastUpdated => 0,
		context => q|Description for the karma field.|
	},

	'form purchase per click' => {
		message => q|@ %f per click|,
		lastUpdated => 0,
		context => q|%f is the price charged for each click on the ad.|
	},

	'form purchase per impression' => {
		message => q|@ %f per impression|,
		lastUpdated => 0,
		context => q|%f is the price charged for each impression of the ad.|
	},

	'minimum impressions' => {
		message => q|Must buy at least %d impressions|,
		lastUpdated => 0,
		context => q|%d is the number of impressions that must be bought.|
	},

	'minimum clicks' => {
		message => q|Must buy at least %d clicks|,
		lastUpdated => 0,
		context => q|%d is the number of clicks that must be bought.|
	},

	'form manage title' => {
		message => q|Manage My Ads|,
		lastUpdated => 0,
		context => q|Text for the title of the form where the user can manage previously purchased advertisements.|
	},

	'form manage link' => {
		message => q|Manage My Ads|,
		lastUpdated => 0,
		context => q|Text for a link to the form where the user can manage previously purchased advertisements.|
	},

	'form purchase link' => {
		message => q|Purchase Ads|,
		lastUpdated => 0,
		context => q|Text for a link to the form where the user can purchase advertisements,|
	},

	'form manage table header title' => {
		message => q|Title|,
		lastUpdated => 0,
		context => q|Header for the adspace manage form: the title field.|
	},

	'form manage table header clicks' => {
		message => q|Clicks|,
		lastUpdated => 0,
		context => q|Header for the adspace manage form: the clicks field.|
	},

	'form manage table header impressions' => {
		message => q|Impressions|,
		lastUpdated => 0,
		context => q|Header for the adspace manage form: the impressions field.|
	},

	'form manage table header renew' => {
		message => q|Renew|,
		lastUpdated => 0,
		context => q|Header for the adspace manage form: the renew field.|
	},

	'form manage table value deleted' => {
		message => q|Deleted|,
		lastUpdated => 0,
		context => q|Contents for the renew field on the manage ads table: indicates a deleted item.|
	},

	'form manage table value renew' => {
		message => q|Renew|,
		lastUpdated => 0,
		context => q|Contents for the renew field on the manage ads table: indicates a renewable item.|
	},

	'form purchase button' => {
		message => q|Add To Cart|,
		lastUpdated => 0,
		context => q|Add the described item to the shopping cart.|
	},

	'form purchase ad title' => {
		message => q|Ad Title|,
		lastUpdated => 0,
		context => q|The title chosen by the buyer for the advertisement.|
	},

	'form purchase ad link' => {
		message => q|Ad Link|,
		lastUpdated => 0,
		context => q|The link the advertisement leads to.|
	},

	'form purchase ad image' => {
		message => q|Image|,
		lastUpdated => 0,
		context => q|The image to be displayed in the ad.|
	},

	'form purchase number of clicks' => {
		message => q|Number of Clicks|,
		lastUpdated => 0,
		context => q|The number of clicks the buyer wishes to purchase.|
	},

	'form purchase number of impressions' => {
		message => q|Number of Impressions|,
		lastUpdated => 0,
		context => q|The number of impressions the user wishes to purchase.|
	},

	'form added to cart thanks' => {
		message => q|Thank you very much for your purchase.|,
		lastUpdated => 0,
		context => q|Thank the customer after adding the item to the cart.|
	},

	'form error no image' => {
		message => q|Please assign an image for this ad.|,
		lastUpdated => 0,
		context => q|remind the user to upload an image for the ad.|
	},

	'form error no title' => {
		message => q|Please enter the title for this ad.|,
		lastUpdated => 0,
		context => q|Remind the user to enter a title for the ad.|
	},

	'form error no link' => {
		message => q|Please enter a valid URL for this ad.|,
		lastUpdated => 0,
		context => q|Remind the user to enter a valid URL for the ad.|
	},

	'form error min clicks' => {
		message => q|You must purchase at least %d clicks for this adSpace.|,
		lastUpdated => 0,
		context => q|Remind the user to that they must purchase a minimum number of clicks, use '%d' to indicate the minimum number of clicks.|
	},

	'form error min impressions' => {
		message => q|You must purchase at least %d impressions for this adSpace.|,
		lastUpdated => 0,
		context => q|Remind the user to that they must purchase a minimum number of impressions, use '%d' to indicate the minimum number of impressions.|
	},

	'view template title' => {
		message => q|Ad Sales View Template.|,
		lastUpdated => 0,
		context => q|Help topic title.|
	},

	'formHeader' => {
		message => q|HTML code to start the form to buy an Ad.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'formFooter' => {
		message => q|HTML code to end the form to buy an Ad.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'formSubmit' => {
		message => q|A button with internationalized label to submit the form.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'error_msg' => {
		message => q|Any errors from submitting the form.  Multiple errors will be joined by break tags.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'hasAddedToCart' => {
		message => q|A boolean which is true when the user has just bought an Ad.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'continueShoppingUrl' => {
		message => q|The URL back to the normal view screen of the Ad Sales asset.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'manageLink' => {
		message => q|The URL to the screen that lists all Ads bought by the current user.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'adSkuTitle' => {
		message => q|The title of this Asset.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'adSkuDescription' => {
		message => q|The description of this Asset.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'formTitle' => {
		message => q|Form for the user to input the title of the Ad.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'formLink' => {
		message => q|Form for the user to input the URL the Ad will link to.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'formImage' => {
		message => q|Form for the user to upload an image for the Ad.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'formClicks' => {
		message => q|Form for the user to enter the number of clicks they want to buy.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'formImpressions' => {
		message => q|Form for the user to enter the number of impressions they want to buy.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'formAdId' => {
		message => q|Hidden form element containing the unique identifier for the Ad.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'clickPrice' => {
		message => q|The price for each click.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'impressionPrice' => {
		message => q|The price for each impression.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'clickDiscount' => {
		message => q|Shows what discounts are available for buying lots of clicks.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'impressionDiscount' => {
		message => q|Shows what discounts are available for buying lots of impressions.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'minimumClicks' => {
		message => q|Shows the minimum number of clicks that must be bought.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'minimumImpressions' => {
		message => q|Shows the minimum number of impressions that must be bought.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'manage template title' => {
		message => q|Ad Sales Manage Template.|,
		lastUpdated => 0,
		context => q|Help topic title.|
	},

	'myAds' => {
		message => q|A loop containing information about all ads bought by the current user.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'rowTitle' => {
		message => q|The title of an Ad.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'rowClicks' => {
		message => q|The number of clicks bought for this Ad, and the number of clicks used so far.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'rowImpressions' => {
		message => q|The number of impressions bought for this Ad, and the number of impressions used so far.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

	'rowRenewLink' => {
		message => q|A link to take the user to a screen where they can purchase additional clicks, impressions and edit their Ad.|,
		lastUpdated => 0,
		context => q|Template variable.|
	},

#	'TODO' => {
#		message => q|TODO|,
#		lastUpdated => 0,
#		context => q|TODO|
#	},

};

1;
