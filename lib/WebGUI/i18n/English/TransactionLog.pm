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

	'help purchase history template body' => {
		message => q|The following template variables are available in this template:<br>
<br>
<b>errorMessage</b><br>
A message with an error concerning the cancellation of recurring payment.<br>
<br>
<b>historyLoop</b><br>
A loop containing the transactions in the transaction history. Within this loop these variables are also available:<br>
<blockquote>
	<b>amount</b><br>
	The total amount of this transaction.<br>
	<br>
	<b>recurring</b><br>
	A boolean that indicates whether this is a recurring transaction or not.<br>
	<br>
	<b>canCancel</b><br>
	A boolean value indicating whether it's possible to cancel this transaction. This is only the case with recurring payments that haven't been canceled yet.<br>
	<br>
	<b>cancelUrl</b><br>
	The URL to visit when you ant to cancel this recurring transaction.<br>
	<br>
	<b>initDate</b><br>
	The date the transaction was initialized.<br>
	<br>
	<b>completionDate</b><br>
	The date on which the transaction has been confirmed.<br>
	<br>
	<b>status</b><br>
	The status for this transaction.<br>
	<br>
	<b>lastPayedTerm</b><br>
	The most recent term that has been payed. This is an integer.<br>
	<br>
	<b>gateway</b><br>
	The payment gateway that was used.<br>
	<br>
	<b>gatewayId</b><br>
	The ID that is assigned to this transaction by the payment gateway.<br>
	<br>
	<b>transactionId</b><br>
	The internal ID that is assigned to this transaction by WebGUI.<br>
	<br>
	<b>userId</b><br>
	The internal WebGUI user ID of the user that performed this transaction.<br>
	<br>
	<b>itemLoop</b>
	This loop contains all items the transaction consists of. These variables are available:<br>
	<blockquote>
		<b>amount</b><br>
		The amount of this item.<br>
		<br>
		<b>itemName</b><br>
		The name of this item.<br>
		<br>
		<b>itemId</b><br>
		The internal WebGUI ID tied to this item.<br>
		<br>
		<b>itemType</b><br>
		The type that this item's of.<br>
		<br>
		<b>quantity</b><br>
		The quantity in which this item is bought.<br>
	</blockquote>
</blockquote>|,
		lastUpdated => 1101753027,
		context => q|The body of the help page of the purchase history template.|
	},
	'help purchase history template title' => {
		message => q|View purchase history template|,
		lastUpdated => 0,
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

