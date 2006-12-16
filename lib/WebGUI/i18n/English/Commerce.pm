package WebGUI::i18n::English::Commerce;

our $I18N = {
        'purchase history template' => {
		message => q|View Purchase History Template|,
		lastUpdated => 0,
		context => q|the title for the workflow activity that processes recurring payments|
	},
        'purchase history template description' => {
		message => q|Controls the layout of the View Purchase History screen.  This screen is displayed to the user after a successful checkout is made and shows them all of their past purchases.|,
		lastUpdated => 0,
		context => q|the title for the workflow activity that processes recurring payments|
	},
	'process recurring payments' => {
		message => q|Process Recurring Payments|,
		lastUpdated => 0,
		context => q|the title for the workflow activity that processes recurring payments|
	},

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

	'payment plugin' => {
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


        'confirm checkout template description' => {
                message => q|<p>This template is shown when a user is asked to confirm his purchase. The form data for the payment gateway is also shown here.</p>|,
                lastUpdated => 1138922899,
        },


        'transaction error template description' => {
                message => q|<p>This is the template that's shown if any error occurs during the payment process. This could be a declined credit card or a false cvv2 code, for instance. Also an 'error' is triggered by a fraud protection filter or some other service that requires manual interaction from the merchant.</p>|,
                lastUpdated => 1138922899,
        },


        'checkout canceled template description' => {
                message => q|<p>This is the template that the user sees when he cancels the transaction. This normally only occurs with remote-side payment gateways (like PayPal). This is because a site-side payment gateway usually uses a single step process.</p>|,
                lastUpdated => 1138922899,
        },


        'checkout select payment template description' => {
                message => q|<p>This is the template that the user sees when he selects a payment after confirming checkout.</p>|,
                lastUpdated => 1138923865,
        },


        'checkout select shipping template description' => {
                message => q|<p>This is the template that the user sees when he selects a shipping method.</p>|,
                lastUpdated => 1138923865,
        },


        'view shopping cart template description' => {
                message => q|<p>This is the template to customize the display of the user's shopping cart.</p>|,
                lastUpdated => 1138923865,
        },


        'shipping plugin label description' => {
                message => q|<p>Select all plugins that can be used for shipping on your site.</p>|,
                lastUpdated => 1138924101,
        },


        'daily report email description' => {
                message => q|<p>Everyday the scheduler plugin that checks and updates subscriptions sends a report with the successful and failed term payments. Here you can set to which email address it should send this report.</p>|,
                lastUpdated => 1138922899,
        },


        'payment plugin description' => {
                message => q|<p>You can select the payment plugin to use here. Please note that you have to enable the plugins you want to choose from in the WebGUI configuration file. If you don't do this they won't show up here.</p>
|,
                lastUpdated => 1147797861,
        },


	'help manage commerce body' => {
		message => q|<p>The commerce system of WebGUI is highly configurable. You can set the following properties:</p>|,
		lastUpdated => 1138922965,
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
		message => q|<p>The status codes have the following meaning:</p>
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

	'list pending transactions' => {
		message => q|List pending transactions|,
		lastUpdated => 0,
	},

	'help manage pending transactions body' => {
		message => q|<p>All transactions that are marked as 'Pending' are listed here. Transactions are marked pending if some extra review is required. For instance when a transaction is suspected of fraud. Pending transactions can also be transactions that have yet to be confirmed by something as or similar to PayPal's APN. If you have checked that the transaction is legit you can click on the 'Complete transaction' link.</p>|,
		lastUpdated => 1165518203,
		context => q|The body of the help page of the list pending transactions screen.|
	},

	'help cancel checkout template title' => {
		message => q|Cancel checkout template|,
		lastUpdated => 0,
		context => q|The title of the help page of the cancel checkout template.|
	},

	'message' => {
		message => q|The internationalized cancellation message.|,
		lastUpdated => 1149221050,
	},

	'help cancel checkout template body' => {
		message => q|<p>The following template variable is available in this template:</p>
|,
		lastUpdated => 1149221067,
		context => q|The body of the help page of the cancel checkout template.|
	},

	'title' => {
		message => q|The title to use for this template.|,
		lastUpdated => 1149221320,
	},

	'normalItems' => {
		message => q|The number of normal items in the shopping cart.|,
		lastUpdated => 1149221320,
	},

	'normalItemLoop' => {
		message => q|A loop containing the normal items in the shopping-cart. The following template variables are available in this loop:|,
		lastUpdated => 1149221320,
	},

	'quantity' => {
		message => q|The quantity of the current item in the shopping cart.<br />|,
		lastUpdated => 1161319738,
	},

	'period' => {
		message => q|The period of the recurring payment.<br />|,
		lastUpdated => 1161319740,
	},

	'name' => {
		message => q|The name of this item.<br />|,
		lastUpdated => 1161319741,
	},

	'price' => {
		message => q|The price of one item.<br />|,
		lastUpdated => 1161319747,
	},

	'totalPrice' => {
		message => q|The price of the quantity of this item. (totalPrice = quantity * price)|,
		lastUpdated => 1161319749,
	},

	'salesTax' => {
		message => q|The amount of sales tax for this item.|,
		lastUpdated => 1161319799,
	},

	'salesTaxRate' => {
		message => q|The sales tax rate, as determined by the user's homeState in his/her profile.|,
		lastUpdated => 1165449949,
	},

	'totalSalesTax' => {
		message => q|The sum of all sales taxes applied to eligible items.|,
		lastUpdated => 1161319799,
	},

	'recurringItems' => {
		message => q|The number of recurring items in the shopping cart.|,
		lastUpdated => 1149221320,
	},

	'recurringItemLoop' => {
		message => q|A loop containing the recurring items in the shopping cart. For available template variables see <p><b>normalItemLoop</b>|,
		lastUpdated => 1161320125,
	},

	'form' => {
		message => q|The form that's generated by the selected payment plugin.|,
		lastUpdated => 1149221320,
	},


	'help checkout confirm template body' => {
		message => q|<p>This template separates normal and recurring items. A normal item is an item that is paid only once. Recurring items are paid once a period, like a subscription.</p>

<p>The following template variables are available in this template:</p>
|,
		lastUpdated => 1165449926,
		context => q|The body of the help page of the confirm checkout template.|
	},


	'help checkout confirm template title' => {
		message => q|Confirm checkout template|,
		lastUpdated => 0,
		context => q|The title of the help page of the confirm checkout template.|
	},

	'statusExplanation' => {
		message => q|A message which explains the possible statuses an item can have|,
		lastUpdated => 1149221449,
	},

	'resultLoop' => {
		message => q|A template loop containing the items that were checked out.|,
		lastUpdated => 1149221449,
	},

	'purchaseDescription' => {
		message => q|The description of this transaction.<br />|,
		lastUpdated => 1161319762,
	},

	'status' => {
		message => q|The status of this item.<br />|,
		lastUpdated => 1161319763,
	},

	'error' => {
		message => q|The error text returned from the payment plugin.<br />|,
		lastUpdated => 1161319765,
	},

	'errorCode' => {
		message => q|The error code returned from the payment plugin.<br />|,
		lastUpdated => 1161319767,
	},


	'help checkout error template body' => {
		message => q|<p>The following template variables are available in this template:</p>

|,
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

	'gateway message' => {
		message => q|This is the message that ask the user to select a payment gateway.|,
		lastUpdated => 1149221607,
	},

	'pluginsAvailable' => {
		message => q|A boolean value that is true when one or more payment plugins can be loaded and are enabled.|,
		lastUpdated => 1149221607,
	},

	'noPluginsMessage' => {
		message => q|A message that says that there are no payment plugins that ca be used.|,
		lastUpdated => 1149221607,
	},

	'formHeader' => {
		message => q|This contains the form header and all hidden form variables that are needed for a successful checkout.|,
		lastUpdated => 1149221607,
	},

	'formFooter' => {
		message => q|The form footer.|,
		lastUpdated => 1149221607,
	},

	'formSubmit' => {
		message => q|The submit button for this form.|,
		lastUpdated => 1149221607,
	},

	'pluginLoop' => {
		message => q|A template loop containing all enabled payment plugins. Within this loop the following template variables are provided:|,
		lastUpdated => 1149221607,
	},

	'plugin name' => {
		message => q|The name of the plugin.|,
		lastUpdated => 1149221607,
	},

	'namespace' => {
		message => q|The namespace of the plugin. You only need this if you want to create your own custom form elements.|,
		lastUpdated => 1149221607,
	},

	'formElement' => {
		message => q|A radio button tied to this plugin.|,
		lastUpdated => 1149221607,
	},

	'help select payment template body' => {
		message => q|<p>In this template the following template variables are available:</p>
|,
		lastUpdated => 1149221754,
		context => q|The body of the help page of the select payment gateway template.|
	},

	'shipping tab' => {
		message => q|Shipping|,
		lastUpdated => 0,
		context => q|The label of the SHipping tab in the commerce settings manager.|
	},

	'salesTax tab' => {
		message => q|SalesTax|,
		lastUpdated => 1159845482,
		context => q|The label of the sales tax tab in the commerce settings manager.|
	},

	'enable sales tax' => {
		message => q|Enable Sales Tax?|,
		lastUpdated => 1160189717,
		context => q|The label field in the commerce setting for enabling sales tax.|
	},

	'enable sales tax description' => {
		message => q|Set this to "Yes" if you would like Sales Tax enabled in the Commerce System.  Sales Tax will be applied to any product, subscription or EMS event that has it enabled.|,
		lastUpdated => 1160189808,
		context => q|The label field in the commerce setting for enabling sales tax.|
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

	'view shopping cart template' => {
		message => q|Select view shopping cart template|,
		lastUpdated => 1134599960,
		context => q|The formlabel for the 'view shopping cart template' option in the commerce part of the admin console.|
	},

	'shopping cart empty' => {
		message => q|Your shopping cart is empty.|,
		lastUpdated => 1134599958,
		context => q|A message indicating that the shopping cart is empty.|
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
