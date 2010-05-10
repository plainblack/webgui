package WebGUI::i18n::English::PayDriver_Cash;
use strict;

our $I18N = {
	'label' => {
                message => q|Cash|,
                lastUpdated => 0,
                context => q|Default Cash payment gateway label|
        },
	
	'module name' => {
		message => q|Cash|,
		lastUpdated => 0,
		context => q|The displayed name of the payment module.|
	},

	'no description' => {
		message => q|No description|,
		lastUpdated => 0,
		context => q|The default description of purchase of users.|
	},
	'cash' => {
		message => q|Cash|,
		lastUpdated => 0,
		context => q|Option to use physical money as a form of payment.|
	},
	'check' => {
		message => q|Check|,
		lastUpdated => 0,
		context => q|Option to use a check as a form of payment.|
	},
	'other' => {
		message => q|Other|,
		lastUpdated => 0,
		context => q|Option to use a something aside from cash or check as a payment.|
	},
	'payment method' => {
		message => q|Payment Method|,
		lastUpdated => 0,
		context => q|Label for selecting how to pay for this purchase.|
	},
	'complete transaction' => {
		message => q|Complete Transaction on Submit?|,
		lastUpdated => 0,
	},
	'complete transaction description' => {
		message => q|When set to 'yes', the transaction is completed when the user submits payment details.  When set to 'no', the transaction is set to pending and must be manually set to complete.  This may be useful if you wish to allow site visitors to select the Cash Payment method, but would like to wait for payment to clear before completing the transaction.|,
		lastUpdated => 0,
	},

    'summary template' => {
        message => q|Summary Template|,
        lastUpdated => 0,
        context => q|Form label in the configuration form of the Cash module.|
    },
    'summary template help' => {
        message => q|Pick a template to display the screen where the user confirms the cart summary info and agrees to pay.|,
        lastUpdated => 0,
        context => q|Hover help for the summary template field in the configuration form of the Cash module.|
    },
 
	'Pay' => {
		message => q|Pay|,
		lastUpdated => 0,
		context => q|Button label|
	},

	'cart summary template' => {
		message => q|Cash Payment Method Cart Summary Template|,
		lastUpdated => 0,
		context => q||,
	},

};

1;

