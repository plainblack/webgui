package WebGUI::i18n::English::PayDriver;

use strict; 

our $I18N = {
	'thank you for your order' => { 
		message => q|Thank You For Your Order|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'a sale has been made' => { 
		message => q|A Sale Has Been Made|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'sale notification template' => { 
		message => q|Sale Notification Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'sale notification template help' => { 
		message => q|Which template should be used to generate the email that notifies this store owner about a new sale.|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'sale notification group' => { 
		message => q|Sale Notification Group|,
		lastUpdated => 0,
		context => q|commerce setting|
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
