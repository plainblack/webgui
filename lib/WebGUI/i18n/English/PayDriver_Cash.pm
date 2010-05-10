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
};

1;

