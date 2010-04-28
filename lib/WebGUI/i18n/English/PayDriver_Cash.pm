package WebGUI::i18n::English::PayDriver_Cash;
use strict;

our $I18N = {
	'label' => {
                message => q|Cash|,
                lastUpdated => 0,
                context => q|Default Cash payment gateway label|
        },
    'phone' => {
                message => q|Telephone Number|,
                lastUpdated => 0,
                context => q|Form label in the checkout form of the iTransact module.|
        },
        'country' => {
                message => q|Country|,
                lastUpdated => 0,
                context => q|Form label in the checkout form of the iTransact module.|
        },
	'firstName' => {
		message => q|First name|,
		lastUpdated => 0,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'lastName' => {
		message => q|Last name|,
		lastUpdated => 0,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'address' => {
		message => q|Address|,
		lastUpdated => 1101772170,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'city' => {
		message => q|City|,
		lastUpdated => 1101772171,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'state' => {
		message => q|State|,
		lastUpdated => 1101772173,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'zipcode' => {
		message => q|Zipcode|,
		lastUpdated => 1101772174,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'email' => {
		message => q|Email|,
		lastUpdated => 1101772176,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'cardNumber' => {
		message => q|Credit card number|,
		lastUpdated => 1101772177,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'expiration date' => {
		message => q|Expiration date|,
		lastUpdated => 1101772180,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'cvv2' => {
		message => q|Verification number (ie. CVV2)|,
		lastUpdated => 1101772182,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	
	'vendorId' => {
		message => q|Username (Vendor ID)|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'use cvv2' => {
		message => q|Use CVV2|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'emailMessage' => {
		message => q|Email message|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'password' => {
		message => q|Password|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},

	'module name' => {
		message => q|Cash|,
		lastUpdated => 0,
		context => q|The displayed name of the payment module.|
	},

	'invalid firstName' => {
		message => q|You have to enter a valid first name.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid first name has been entered.|
	},
	'invalid lastName' => {
		message => q|You have to enter a valid last name.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid last name has been entered.|
	},
	'invalid address' => {
		message => q|You have to enter a valid address.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid street has been entered.|
	},
	'invalid city' => {
		message => q|You have to enter a valid city.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid city has been entered.|
	},
	'invalid zip' => {
		message => q|You have to enter a valid zipcode.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid zipcode has been entered.|
	},
	'invalid email' => {
		message => q|You have to enter a valid email address.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid email address has been entered.|
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
 
	'password' => {
		message => q|Password|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'password help' => {
		message => q|The password for your ITransact account.|,
		lastUpdated => 0,
		context => q|Hover help for the password field in the configuration form of the iTransact module.|
	},
	'Pay' => {
		message => q|Pay|,
		lastUpdated => 0,
		context => q|Button label|
	},
};

1;

