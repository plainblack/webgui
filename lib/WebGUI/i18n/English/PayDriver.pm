package WebGUI::i18n::English::PayDriver;

use strict; 

our $I18N = {
	'receipt subject' => {
		message 	=> q|Receipt for Order #|,
		lastUpdated	=> 0,
		context		=> q|notice after purchase|,
	},
	
	'a sale has been made' => { 
		message => q|A sale has been made. Order #|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'sale notification group' => { 
		message => q|Sale Notification Group|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'error processing payment' => { 
		message => q|Error Processing Payment|,
		lastUpdated => 0,
		context => q|the title of the error screen|
	},

	'error processing payment message' => { 
		message => q|There has been an error processing your payment. Usually this is caused by typing errors. However, there may be a connectivity problem, or your account may not have the funds required to complete this transaction. The error message we received is below. Use your browser's back button to go back and correct mistakes. If this problem persists please contact us.|,
		lastUpdated => 0,
		context => q|the description on the error screen|
	},

	'sale notification group help' => { 
		message => q|Who should be notified of new transactions?|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'receipt email template' => { 
		message => q|Receipt Email Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'receipt email template help' => { 
		message => q|Which template should be used to generate an email that will be sent to the user to acknowledge their purchase?|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'label' => {
		message => q|Label|,
		lastUpdated => 0,
		context => q|Label for the label option.|
	},

	'label help' => {
		message => q|The name by which this pagyment gateway is displayed.|,
		lastUpdated => 0,
		context => q|Hover help for the label option.|
	},

    'enabled' => {
        message => q|Enabled|,
        lastUpdated => 0,
        context => q|Label for the enabled option.|,
    },

    'enabled help' => {
        message => q|Sets whether this payment gateway is enabled|,
        lastUpdated => 0,
        context => q|Hover help for the enabled option.|,

    },

    'who can use' => {
        message => q|Group to use this gateway|,
        lastUpdate => 0,
        context => q|Label for the group to use option.|,
    },

    'who can use help' => {
        message => q|Specifies which group is allowed to use this payment gateway.|,
        lastUpdated => 0,
        context => q|Hover help for the group to use option.|,
    },

};

1;
