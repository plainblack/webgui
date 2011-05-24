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

	'label' => {
		message => q|Label|,
		lastUpdated => 0,
		context => q|Label for the label option.|
	},

	'label help' => {
		message => q|The name by which this payment gateway is displayed in the Payment methods screen.|,
		lastUpdated => 1215799966,
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

    'email receipt template' => {
        message => q|Email Receipt Template|,
        lastUpdated => 1213121298,
        context => q|Title of the Email Receipt Template help page|,
    },

    'email receipt template help' => {
        message => q|This template is for email receipts sent to the user.|,
        lastUpdated => 1213121298,
        context => q|Help body for the email receipt template|,
    },

    'payment methods' => {
        message => q|Payment Methods|,
        lastUpdated => 1213313375,
        context => q|Help body for the email receipt template|,
    },

    'credit card' => {
        message => q|Credit Card|,
        lastUpdated => 1215799807,
        context => q|Generic label for credit cards to be used through the pay drivers|,
    },

    'try again' => {
        message     => q{Go back to try again},
        lastUpdated => 0,
        context     => q{Link to begin checkout again after failure},
    },

	'template gone' => {
		message => q|The template for entering in credentials has been deleted.  Please notify the site administrator.|,
		lastUpdated => 0,
		context => q|Error message when a template cannot be accessed.|
	},

	'cart summary variables' => {
		message => q|Cart Summary Variables|,
		lastUpdated => 0,
		context => q|Title for a template variable help page.|
	},

	'cart summary variables help' => {
		message => q|These variables should be available in all PayDriver templates, to display the cart summary to the user.|,
		lastUpdated => 0,
		context => q|Body for a template variable help page.|
	},

    'proceedButton' => {
        message => q|A combined button and form for the user to press when they have reviewed the charges that will be submitted to this payment gateway.|,
        lastUpdated => 0,
        context => q|Status message|,
    },

    'unable to finish transaction' => {
        message => q|We are unable to lookup the transaction to finish checking out.|,
        lastUpdated => 0,
        context => q|Error message when the transaction cannot be looked up.|,
    },

};

1;
