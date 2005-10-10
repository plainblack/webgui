package WebGUI::i18n::English::Commerce;

our $I18N = {
	'commerce settings' => {
		message => q|Commerce|,
		lastUpdated => 1101772584,
		context => q|The displayed title of the Commerce Settings in the Admin Console|
	},
	'pay button' => {
		message => q|Pay|,
		lastUpdated => 0,
		context => q|The button on the checkout form.|
	},
	'checkout confirm title' => {
		message => q|Please fill in the form below to purchase these products.|,
		lastUpdated => 0,
		context => q|Message in the checkout form.|
	},
	'general tab' => {
		message => q|General|,
		lastUpdated => 0,
		context => q|The name of the 'general' tab in editCommerce.|
	},
	'payment tab' => {
		message => q|Payment Plugins|,
		lastUpdated => 0,
		context => q|The name of the 'payment plugins' tab in editCommerce.|
	},
	'payment form' => {
		message => q|Payment Plugin|,
		lastUpdated => 0,
		context => q|The name of the 'payment plugin' form option in editCommerce.|
	},
	'confirm checkout template' => {
		message => q|Confirm checkout template|,
		lastUpdated => 0,
		context => q|Form label indicating the Confirm checkout template.|
	},
	'checkout canceled template' => {
		message => q|Checkout canceled template|,
		lastUpdated => 0,
		context => q|Form label indicating the Checkout canceled template.|
	},
	'transaction error template' => {
		message => q|Transaction error template|,
		lastUpdated => 0,
		context => q|Form label indicating the Transaction error template.|
	},
	'no payment gateway' => {
		message => q|No payment gateway selected.|,
		lastUpdated => 0,
		context => q|An error message that shows up during checkout process if no payment gateway has been selected|
	},
	'edit commerce settings title' => {
		message => q|Manage Commerce Settings|,
		lastUpdated => 0,
		context => q|Title of the Commerce part of the Admin Console.|
	},

	'help manage commerce title' => {
		message => q|Commerce, Manage|,
		lastUpdated => 0,
		context => q|The title of the manage commerce help page.|
	},

	'help manage commerce body' => {
		message => q|The commerce system of WebGUI is highly configurable. You can set the following properties:<p>

<b>^International("confirm checkout template","Commerce");</b><br>
This template is shown when a user is asked to confirm his purchase. The form data for the payment gateway is also shown here.<br>
<br>

<b>^International("transaction error template","Commerce");</b><br>
This is the template that's shown if any error occurs during the payment process. This could be a declined credit card or a false cvv2 code, for instance. Also an 'error' is triggered by a fraud protection filter or some other service that requires manual interaction from the merchant.<br>
<br>

<b>^International("checkout canceled template","Commerce");</b><br>
This is the template that the user sees when he cancels the transaction. This normally only occurs with remote-side payment gateways (like PayPal). This is because a site-side payment gateway usually uses a single step process.<br>
<br>

<b>^International("daily report email","Commerce");</b>
Everyday the scheduler plugin that checks and updates subscriptions send a report on on the successful and failed term payments. Here you can set to which email address it should send this report.<br>
<br>

<b>Payment plugin</b><br>
You can select the payment plugin to use here. Please note that you have to enable the plugins you want to choose from in the WebGUI configuration file. If you don't do this they won't show up here.<br>
<br>
<h3>PayflowPro</h3>
This is the plugin for Verisign Payflow Pro. This plugin is disabled by default in the configuration file because it depends on proprietary software from Verisign that can't be shipped with WebGUI.<br>
<br>
<b>Partner</b><br>
Your partner id.<br>
<br>
<b>Vendor</b>
Here you should enter your vendor id.<br>
<br>
<b>Login</b>
Your login to Verisign PayflowPro.<br>
<br>
<b>Password</b>
Your password.<br>|,
		lastUpdated => 1101881895,
		context => q|The content of the manage commerce help page.|
	},

	'manage commerce settings' => {
		message => q|Manage commerce settings.|,
		lastUpdated => 1101772609,
		context => q|The menu title for 'Manage commerce settings' in the AdminConsole side menu.|
	},

	'pending transactions' => {
		message => q|Show pending transactions.|,
		lastUpdated => 1101772617,
		context => q|The menu title for 'Show pending transactions' in the AdminConsole side menu.|
	},

	'transactionId' => {
		message => q|TransactionId|,
		lastUpdated => 0,
		context => q|TransactionId, just leave it as it is.|
	},


	'gatewayId' => {
		message => q|Gateway ID|,
		lastUpdated => 0,
		context => q|Gateway ID is the ID the transaction is given by the payment gateway.|,
	},

	'init date' => {
		message => q|Initiation Date|,
		lastUpdated => 0,
		context => q|The date on which the transaction was started|
	},

	'gateway' => {
		message => q|Gateway|,
		lastUpdated => 0,
		context => q|Table header of the column that identifies the gateway through which the transaction went.|
	},

	'weekly' => {
		message => q|Week|,
		lastUpdated => 0,
		context => q|Period name for a weekly subscription.|
	},
	
	'biweekly' => {
		message => q|Two weeks|,
		lastUpdated => 0,
		context => q|Period name for a biweekly subscription.|
	},

	'fourweekly' => {
		message => q|Four weeks|,
		lastUpdated => 0,
		context => q|Period name for a four weekly subscription.|
	},

	'monthly' => {
		message => q|Month|,
		lastUpdated => 0,
		context => q|Period name for a monthly subscription.|
	},

	'quarterly' => {
		message => q|Three months|,
		lastUpdated => 0,
		context => q|Period name for a Quarterly subscription.|
	},

	'halfyearly' => {
		message => q|Half year|,
		lastUpdated => 0,
		context => q|Period name for a semi yearly subscription.|
	},
	
	'yearly' => {
		message => q|Year|,
		lastUpdated => 0,
		context => q|Period name for a yearly subscription.|
	},

	'transaction error' => {
		message => q|Transaction Error|,
		lastUpdated => 0,
		context => q|Name for 'transaction error' status in the Commerce/TransactionError template.|
	},
	
	'connection error' => {
		message => q|Connection Error|,
		lastUpdated => 0,
		context => q|Name for 'connection error' status in the Commerce/TransactionError template.|
	},
	
	'pending' => {
		message => q|Pending|,
		lastUpdated => 0,
		context => q|Name for 'pending' status in the Commerce/TransactionError template.|
	},
	
	'ok' => {
		message => q|OK|,
		lastUpdated => 0,
		context => q|Name for 'OK' status in the Commerce/TransactionError template.|
	},

	'transaction error title' => {
		message => q|An error has occurred in one or more transactions|,
		lastUpdated => 0,
		context => q|The title used in the transaction error template.|
	},

	'status codes information' => {
		message => q|The status codes have the following meaning:<br>
<table border="0" cellspacing="0" cellpadding="5">
	<tr>
		<td valign="top" align="right"><b>^International("ok","Commerce");</b></td>
		<td valign="top" align="left">This means that this transaction has been completed successfully. You have purchased the product.</td>
	</tr><tr>
		<td valign="top" align="right"><b>^International("pending","Commerce");</b></td>
		<td valign="top" align="left">This means that this transaction is under review. This could have a number of causes, and normally this transaction is processed within a short time.</td>
	</tr><tr>
		<td valign="top" align="right"><b>^International("transaction error","Commerce");</b></td>
		<td valign="top" align="left">An unrecoverable error happened while processing the transaction.</td>
	</tr><tr>
		<td valign="top" align="right"><b>^International("transaction error","Commerce");</b></td>
		<td valign="top" align="left">Something went wrong with the connection to the payment gateway. The admin has been notified.</td>
	</tr>
</table>|,
		lastUpdated => 1110148219,
		context => q|A message that explains the status codes that are returned in the transaction error template.|
	},

	'daily report email' => {
		message => q|Send daily report to|,
		lastUpdated => 0,
		context => q|Form label that asks whom to send the daily recurring payments report to.|
	},
	'checkout canceled message' => {
		message => q|The checkout process has been canceled.|,
		lastUpdated => 0,
		context => q|A message that's shown to users that cancel their checkout.|
	},
	'complete pending transaction' => {
		message => q|Complete transaction|,
		lastUpdated => 0,
		context => q|Label for the link that allows you to complete a pending transaction.|
	},
	'help manage pending transactions title' => {
		message => q|List pending transactions|,
		lastUpdated => 0,
		context => q|The title of the help page of the list pending transactions screen.|
	},
	'help manage pending transactions body' => {
		message => q|All transactions that are marked as 'Pending' are listed here. Transactions are marked pending if some extra review is required. For instance when a transaction is suspected of fraud. Pending transactions can also be transactions that yet have to be confirmed by something as or similar to PayPal's APN. If you have checked that the transaction is legit you can click on the 'Complete transaction' link.|,
		lastUpdated => 1101772650,
		context => q|The body of the help page of the list pending transactions screen.|
	},



	
	'help cancel checkout template title' => {
		message => q|Cancel checkout template|,
		lastUpdated => 0,
		context => q|The title of the help page of the cancel checkout template.|
	},
	'help cancel checkout template body' => {
		message => q|The following template variable is available in this template:<br>
<br>
<b>message</b><br>
The internationalized cancellation message.|,
		lastUpdated => 1101772660,
		context => q|The body of the help page of the cancel checkout template.|
	},
	'help checkout confirm template body' => {
		message => q|This template separates normal and recurring items. A normal item is an item that is payed only once. Recurring items are payed once a period, like a subscription.<br>
<br>
The following template variables are available in this template:<br>
<br>
<b>title</b><br>
The title to use for this template.<br>
<br>
<b>normalItems</b><br>
Th number of normal items in the shopping cart.<br>
<br>
<b>normalItemLoop</b>
A loop containing the normal items in the shopping-cart. The following template variables are available in this loop:<br>
<blockquote>
	<b>quantity</b><br>
	The quantity of the current item in the shopping cart.<br>
	<br>
	<b>period</b><br>
	The period of the recurring payment.<br>
	<br>
	<b>name</b><br>
	The name of this item.<br>
	<br>
	<b>price</b><br>
	The price of one item.<br>
	<br>
	<b>totalPrice</b><br>
	The price of the quantity of this item. (totalPrice = quantity * price)<br>
	</blockquote>
<b>recurringItems</b><br>
The number of recurring items in the shopping cart.<br>
<br>
<b>recurringItemLoop</b><br>
A loop containing the recurring items in the shopping cart. For available template variables seen <b>normalItemLoop</b><br>
<br>
<b>form</b><br>
The form that's generated by the selected payment plugin.<br>|,
		lastUpdated => 1101772672,
		context => q|The body of the help page of the confirm checkout template.|
	},
	'help checkout confirm template title' => {
		message => q|Confirm checkout template|,
		lastUpdated => 0,
		context => q|The title of the help page of the confirm checkout template.|
	},
	'help checkout error template body' => {
		message => q|The following template variables are available in this template:<br>
<br>
<b>title</b><br>
The title of this template.<br>
<br>
<b>statusExplanation</b><br>
A message which explains the possible statuses an item can have<br>
<br>
<b>resultLoop</b><br>
A template loop containing the items that were checked out. The following template variables are available from within this loop:<br>
<blockquote>
	<b>purchaseDescription</b><br>
	The description of this transaction.<br>
	<br>	
	<b>status</b><br>
	The status of this item.<br>
	<br>
	<b>error</b><br>
	The error text returned from the payment plugin.<br>
	<br>
	<b>errorCode</b><br>
	The error code returned from the payment plugin.<br>
</blockquote>|,
		lastUpdated => 0,
		context => q|The body of the help page of the checkout error template.|
	},
	'help checkout error template title' => {
		message => q|Checkout error template|,
		lastUpdated => 1101791348,
		context => q|The title of the help page of the checkout error template.|
	},
	'no payment plugins selected' => {
		message => q|There are no payment plugins to select. Please enable plugins in the config file.|,
		lastUpdated => 0,
		context => q|The message that's shown in the AdminConsole/Commerce menu when there are no payment plugins enabled.|
	},
	'failed payment plugins' => {
		message => q|The following Payment Plugins failed to compile, please check your log for more information: |,
		lastUpdated => 1101881907,
		context => q|The message that says which payment plugins did not compile.|
	},
	'select payment gateway'=> {
		message => q|Please select a payment gateway.|,
		lastUpdated => 0,
		context => q|The message that asks the user to select a payment gateway.|
	},
	'payment gateway select' => {
		message => q|Select gateway|,
		lastUpdated => 0,
		context => q|The text on the submit button of the select gateway form.|
	},
	'checkout select payment template' => {
		message => q|Select payment gateway template|,
		lastUpdated => 0,
		context => q|The formlabel for the 'select payment gateway template' option in the commerce part of the admin console.|
	},
	'help select payment template title' => {
		message => q|Select payment gateway template|,
		lastUpdated => 0,
		context => q|The title of the 'select payment gateway' help page.|
	},
	'help select payment template body' => {
		message => q|In this template the following template variables are available:<br>
<br>
<b>message</b><br>
This is the message that ask the user to select a payment gateway.<br>
<br>
<b>pluginsAvailable</b><br>
A boolean value that is true when one or more payment plugins can be loaded and are enabled.<br>
<br>
<b>noPluginsMessage</b><br>
A message that says that there are no payment plugins that ca be used.<br>
<br>
<b>formHeader</b><br>
This contains the form header and all hidden form variables that are needed for a successful checkout.<br>
<br>
<b>formFooter</b><br>
The form footer.<br>
<br>
<b>formSubmit</b><br>
The submit button for this form.<br>
<br>
<b>pluginLoop</b><br>
A template loop containing all enabled payment plugins. Within this loop the following template variables are provided:
<blockquote>
<b>name</b><br>
The name of the plugin.<br>
<br>
<b>namespace</b><br>
The namespace of the plugin. You only need this if you want to create your own custom form elements.<br>
<br>
<b>formElement</b><br>
A radio button tied to this plugin.<br>
</blockquote>|,
		lastUpdated => 1101881921,
		context => q|The body of the help page of the select payment gateway template.|
	},
	'shipping tab' => {
		message => q|Shipping|,
		lastUpdated => 0,
		context => q|The label of the SHipping tab in the commerce settings manager.|
	},
	'shipping plugin label' => {
		message => q|Shipping plugin|,
		lastUpdated => 0,
		context => q|The label of the shipping plugin selection box in the commerce settings manager.|
	},
	'no shipping plugins selected' => {
		message => q|There are no shipping plugins to select. Please enable plugins in the config file.|,
		lastUpdated => 0,
		context => q|The message that's shown in the AdminConsole/Commerce menu when there are no shipping plugins enabled.|
	},
	'select shipping method' => {
		message => q|Please select a shipping method.|,
		lastUpdated => 0,
		context => q|The message asking the user to choose a shipping method during checkout.|
	},
	'no shipping methods available' => {
		message => q|Shipping is not possible because no shipping plugins are enabled.|,
		lastUpdated => 0,
		context => q|A message that is shown when a user tries to checkout but no shipping plugins are enabled.|
	},
	'shipping select button' => {
		message => q|Select shipping method|,
		lastUpdated => 0,
		context => q|The label of the select button of the select shipping form the user sees during checkout.|
	},
	'enable' => {
		message => q|Enable|,
		lastUpdated => 0,
		context => q|The label of the enable option of the commerce plugins.|
	},
	'change payment gateway' => {
		message => q|Change payment gateway|,
		lastUpdated => 0,
		context => q|The label for the change payament gateway url.|
	},
	'change shipping method' => {
		message => q|Change shipping method|,
		lastUpdated => 0,
		context => q|The label for the change shipping method url.|
	},
	'checkout select shipping template' => {
		message => q|Select shipping method template|,
		lastUpdated => 0,
		context => q|The formlabel for the 'select shipping method template' option in the commerce part of the admin console.|
	},
	'shopping cart empty' => {
		message => q|Your shopping cart is empty.|,
		lastUpdated => 0,
		context => q|A message indicating that te shopping cart is empty.|
	},
	'update cart' => {
		message => q|Update cart|,
		lastUpdated => 0,
		context => q|The label of the update cart button.|
	},
	'checkout' => {
		message => q|Checkout|,
		lastUpdated => 0,
		context => q|The label of the checkout button.|
	},
	'list transactions' => {
		message => q|List transactions|,
		lastUpdated => 0,
		context => q|List transactions label|
	},
	'view shopping cart' => {
		message => q|View shopping cart|,
		lastUpdated => 0,
		context => q|The label for the view shopping cart link in the confirm checkout screen.|
	},
	'topicName' => {
		message => q|Commerce|,
		lastUpdated => 1128920490,
	},

};

1;
