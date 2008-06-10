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

    'viewDetailURL' => {
        message => q|A URL for viewing more details about the user's transaction.|,
        lastUpdated => 1213121298,
        context => q|Template variable for email receipt template|,
    },

    'amount' => {
        message => q|The total amount of this transaction, formatted to two decimal places.|,
        lastUpdated => 1213121298,
        context => q|Template variable for email receipt template|,
    },

    'taxes' => {
        message => q|Taxes for this transaction, formatted to two decimal places.|,
        lastUpdated => 1213121298,
        context => q|Template variable for email receipt template|,
    },

    'shippingPrice' => {
        message => q|Shipping price for this transaction, formatted to two decimal places.|,
        lastUpdated => 1213121298,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddress' => {
        message => q|Formatted shipping address.|,
        lastUpdated => 1213121298,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddress' => {
        message => q|Formatted payment/billing address.|,
        lastUpdated => 1213121298,
        context => q|Template variable for email receipt template|,
    },

    'items' => {
        message => q|A loop containing all items associated with this transaction.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'transactionId' => {
        message => q|The unique identifier for this transaction.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'originatingTransactionId' => {
        message => q|If the transaction is a recurring transaction, this will contain the transactionId for the original purchase.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'isSuccessful' => {
        message => q|Whether or not this transaction completed successfully.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'orderNumber' => {
        message => q|A human readable number for the transaction.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'transactionCode' => {
        message => q|Transaction code or ID given by the payment gateway.  Not all gateways may support this.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'statusCode' => {
        message => q|The status code that came back from the gateway when trying to process the payment.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'statusMessage' => {
        message => q|The extended status message that came back from the payment gateway when trying to process the payment.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'userId' => {
        message => q|The userId of the user who performed this transaction.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'username' => {
        message => q|The name of the user who performed this transaction, to save you a username lookup.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'shopCreditDeduction' => {
        message => q|The unformatted amount of shop credit used in this transaction.|,
        lastUpdated => 1213132212,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddressId' => {
        message => q|The ID of the shipping address used for this transaction.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddressName' => {
        message => q|The name assigned to the shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddress1' => {
        message => q|The first line in a multi-line shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddress2' => {
        message => q|The second line in a multi-line shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddress3' => {
        message => q|The third line in a multi-line shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddressCity' => {
        message => q|The city from the shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddressState' => {
        message => q|The state from the shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddressCountry' => {
        message => q|The state from the shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddressCode' => {
        message => q|The code from the shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingAddressPhoneNumber' => {
        message => q|The phone number from the shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingDriverId' => {
        message => q|The unique identifier for the shipping driver used in this transaction.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'shippingDriverLabel' => {
        message => q|The label for the shipping driver used in this transaction.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddressId' => {
        message => q|The ID of the payment address used for this transaction.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddressName' => {
        message => q|The name assigned to the payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddress1' => {
        message => q|The first line in a multi-line payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddress2' => {
        message => q|The second line in a multi-line payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddress3' => {
        message => q|The third line in a multi-line payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddressCity' => {
        message => q|The city from the payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddressState' => {
        message => q|The state from the payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddressCountry' => {
        message => q|The state from the payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddressCode' => {
        message => q|The code from the payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddressCode' => {
        message => q|The code from the payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'paymentAddressPhoneNumber' => {
        message => q|The phone number from the payment address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'dateOfPurchase' => {
        message => q|The date the purchase occurred.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'isRecurring' => {
        message => q|A boolean that is true if this is a recurring transaction.|,
        lastUpdated => 1213134691,
        context => q|Template variable for email receipt template|,
    },

    'notes' => {
        message => q|Notes about this transaction.|,
        lastUpdated => 1213134744,
        context => q|Template variable for email receipt template|,
    },

    'viewItemUrl' => {
        message => q|A URL to view details about this item from the transaction.|,
        lastUpdated => 1213135218,
        context => q|Template variable for email receipt template|,
    },

    'price' => {
        message => q|The price of this item, formatted to two decimal places.|,
        lastUpdated => 1213135218,
        context => q|Template variable for email receipt template|,
    },

    'itemShippingAddress' => {
        message => q|The formatted shipping address for this item.|,
        lastUpdated => 1213135307,
        context => q|Template variable for email receipt template|,
    },

    'orderStatus' => {
        message => q|The internationalized status of this item, Shipped, Canceled, Backordered or Not Shipped.|,
        lastUpdated => 1213135307,
        context => q|Template variable for email receipt template|,
    },

    'item transactionId' => {
        message => q|The ID of the transaction that this item belongs to.|,
        lastUpdated => 1213135697,
        context => q|Template variable for email receipt template|,
    },

    'itemId' => {
        message => q|The unique identifier for this item among all items in all transactions.|,
        lastUpdated => 1213135697,
        context => q|Template variable for email receipt template|,
    },

    'item assetId' => {
        message => q|The assetId for this item.|,
        lastUpdated => 1213135697,
        context => q|Template variable for email receipt template|,
    },

    'configuredTitle' => {
        message => q|The configured title for the assetId.  This is the regular title of the asset with customizations from the user.|,
        lastUpdated => 1213135697,
        context => q|Template variable for email receipt template|,
    },

    'item options' => {
        message => q|JSON encoded options for the asset.  You should probably not use this template variable.|,
        lastUpdated => 1213135697,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddressId' => {
        message => q|The ID of the shipping address used for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingName' => {
        message => q|The name assigned to the shipping address for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddress1' => {
        message => q|The first line in a multi-line shipping address for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddress2' => {
        message => q|The second line in a multi-line shipping address for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddress3' => {
        message => q|The third line in a multi-line shipping address for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddressCity' => {
        message => q|The city from the shipping address for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddressState' => {
        message => q|The state from the shipping address for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddressCountry' => {
        message => q|The state from the shipping address for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddressCode' => {
        message => q|The code from the shipping address for this item.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item shippingAddressPhoneNumber' => {
        message => q|The phone number from the shipping address.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item lastUpdated' => {
        message => q|The date this transaction item was last updated.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item quantity' => {
        message => q|The quantity of the SKU that was purchased.|,
        lastUpdated => 1213133715,
        context => q|Template variable for email receipt template|,
    },

    'item price' => {
        message => q|The unformatted price of this SKU.|,
        lastUpdated => 1213137846,
        context => q|Template variable for email receipt template|,
    },

    'item vendorId' => {
        message => q|The ID of the vendor of this item.|,
        lastUpdated => 1213137846,
        context => q|Template variable for email receipt template|,
    },

};

1;
