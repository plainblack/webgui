package WebGUI::i18n::English::TransactionLog;

our $I18N = {
	'cancel error' => {
		message => q|An error has occurred while canceling the recurring transaction. Please contact the admin. Error: |,
		lastUpdated => 1101752984,
		context => q|An error message that's shown when a subscription cancellation fails.|
	},

	'cannot cancel' => {
		message => q|You cannot cancel a non recurring transaction|,
		lastUpdated => 1101753015,
		context => q|An error message that's shown when an attempt is made to cancel a non recurring transaction.|
	},

	'errorMessage' => {
		message => q|A message with an error concerning the cancellation of recurring payment.|,
		lastUpdated => 1149222142,
	},

	'historyLoop' => {
		message => q|A loop containing the transactions in the transaction history. Within this loop these variables are also available:|,
		lastUpdated => 1149222142,
	},

	'amount.template' => {
		message => q|The total amount of this transaction.|,
		lastUpdated => 1149222142,
	},

	'recurring' => {
		message => q|A boolean that indicates whether this is a recurring transaction or not.|,
		lastUpdated => 1149222142,
	},

	'canCancel' => {
		message => q|A boolean value indicating whether it's possible to cancel this transaction. This is only the case with recurring payments that haven't been canceled yet.|,
		lastUpdated => 1149222142,
	},

	'cancelUrl' => {
		message => q|The URL to visit when you ant to cancel this recurring transaction.|,
		lastUpdated => 1149222142,
	},

	'initDate' => {
		message => q|The date the transaction was initialized.|,
		lastUpdated => 1149222142,
	},

	'completionDate' => {
		message => q|The date on which the transaction has been confirmed.|,
		lastUpdated => 1149222142,
	},

	'status.template' => {
		message => q|The status for this transaction.|,
		lastUpdated => 1149222142,
	},

	'lastPayedTerm' => {
		message => q|The most recent term that has been paid. This is an integer.|,
		lastUpdated => 1167190416,
	},

	'gateway' => {
		message => q|The payment gateway that was used.|,
		lastUpdated => 1149222142,
	},

	'gatewayId' => {
		message => q|The ID that is assigned to this transaction by the payment gateway.|,
		lastUpdated => 1149222142,
	},

	'transactionId' => {
		message => q|The internal ID that is assigned to this transaction by WebGUI.|,
		lastUpdated => 1149222142,
	},

	'userId' => {
		message => q|The internal WebGUI user ID of the user that performed this transaction.|,
		lastUpdated => 1149222142,
	},

    'username' => {
        message => q|User|,
        lastUpdated => 1185302874,
    },
	'itemLoop' => {
		message => q|This loop contains all items the transaction consists of. These variables are available:|,
		lastUpdated => 1149222142,
	},

	'amount.template' => {
		message => q|The amount of this item.|,
		lastUpdated => 1149222142,
	},

	'itemName' => {
		message => q|The name of this item.|,
		lastUpdated => 1149222142,
	},

	'itemId' => {
		message => q|The internal WebGUI ID tied to this item.|,
		lastUpdated => 1149222142,
	},

	'itemType' => {
		message => q|The type that this item's of.|,
		lastUpdated => 1149222142,
	},

	'quantity' => {
		message => q|The quantity in which this item is bought.|,
		lastUpdated => 1149222142,
	},

	'help purchase history template title' => {
		message => q|View purchase history template variables|,
		lastUpdated => 1184781026,
		context => q|The title of the help page of the purchase history template.|
	},

	'init date' => {
		message => q|Init date|,
		lastUpdated => 0,
		context => q|Init date label.|
	},

	'completion date' => {
		message => q|Completion date|,
		lastUpdated => 0,
		context => q|Completion date label|
	},
	'and' => {
		message => q|and|,
		lastUpdated => 0,
		context => q|The word 'and'|
	},
	'transaction status' => {
		message => q|Transaction status|,
		lastUpdated => 0,
		context => q|Transaction status label.|
	},
	'shipping status' => {
		message => q|Shipping status|,
		lastUpdated => 0,
		context => q|Shipping status label.|
	},
	'select' => {
		message => q|Select|,
		lastUpdated => 0,
		context => q|Select button label.|
	},
	'list transactions title' => {
		message => q|List transactions|,
		lastUpdated => 0,
		context => q|List transaction workarea title.|
	},

	'selection message' => {
		message => q|Use the form below to select which transactions you want to view.|,
		lastUpdated => 1134665021,
		context => q|List transaction message.|
	},

	'topicName' => {
		message => q|Transaction Log|,
		lastUpdated => 1128920040,
		context => q|An error message that's shown when an attempt is made to cancel a non recurring transaction.|
	},
	'pending' => {
		message => q|Pending|,
		lastUpdated => 1135291532,
	},
	'completed' => {
		message => q|Completed|,
		lastUpdated => 1135291540,
	},
	'shipped' => {
		message => q|Shipped|,
		lastUpdated => 1135291545,
	},
	'not shipped' => {
		message => q|Not Shipped|,
		lastUpdated => 1135291589,
	},
	'any' => {
		message => q|Any|,
		lastUpdated => 1135291967,
	},
	'delivered' => {
		message => q|Delivered|,
		lastUpdated => 1135291969,
	},
	'amount' => {
		message => q|Amount|,
		lastUpdated => 1139422433,
	},
	'shipping cost' => {
		message => q|Shipping Cost|,
		lastUpdated => 1139422453,
	},
	'status' => {
		message => q|Status|,
		lastUpdated => 1139422455,
	},
	
};

1;

