package WebGUI::i18n::English::Shop;

use strict;

our $I18N = { 
	'Preferred Payment Type' => {
		message 	=> q|Preferred Payment Type|,
		lastUpdated	=> 0,
		context		=> q|vendor label|,
	},

    'cashier' => {
        message     => q|Cashier|,
        lastUpdated    => 0,
        context        => q|transaction label|,
    },

    'order for' => {
        message     => q|Order For|,
        lastUpdated    => 0,
        context        => q|cart label, as in "This is an order for John Smith"|,
    },

    'search for email' => {
        message     => q|Search for Email Address|,
        lastUpdated    => 0,
        context        => q|cart button label|,
    },

    'who is a cashier' => {
        message     => q|Who is a cashier?|,
        lastUpdated    => 0,
        context        => q|shop admin setting|,
    },

    'who is a cashier help' => {
        message     => q|Cashiers are able to make purchases on behalf of another user by typing the email address of the user into the cart.|,
        lastUpdated    => 0,
        context        => q|help for shop admin setting|,
    },

    'organization' => {
        message     => q|Organization|,
        lastUpdated    => 0,
        context        => q|address book label|,
    },

    'organization help' => {
        message     => q|The name of an organization that uses this address.  Probably the place you work.|,
        lastUpdated    => 1227495231,
        context        => q|address book template variable hover help|,
    },

    'email' => {
        message     => q|Email|,
        lastUpdated    => 0,
        context        => q|address book label|,
    },

	'Payment Information' => {
		message 	=> q|Payment Information|,
		lastUpdated	=> 0,
		context		=> q|vendor label|,
	},

	'thank you message' => {
		message 	=> q|Thank you for your order! Please save this as your receipt.|,
		lastUpdated	=> 0,
		context		=> q|notice after purchase|,
	},

	'shop notice' => {
		message 	=> q|Shop Notice|,
		lastUpdated	=> 0,
		context		=> q|an email subject heading for generic shop notification emails|,
	},

	'mixed items warning' => {
		message 	=> q|You are not able to check out with both recurring and non-recurring items in your cart. You may have either one recurring item, or as many non-recurring items as you want in your cart at checkout time. If you need to purchase both, then please purchase them under separate transactions.|,
		lastUpdated	=> 0,
		context		=> q|a warning message displayed in the cart|,
	},

	'cancel recurring transaction' => {
		message 	=> q|Cancel Recurring Transaction|,
		lastUpdated	=> 0,
		context		=> q|a link label|,
	},

	'print' => {
		message 	=> q|Print|,
		lastUpdated	=> 0,
		context		=> q|a link label|,
	},

	'minicart template' => {
		message 	=> q|MiniCart Template|,
		lastUpdated	=> 0,
		context		=> q|a help title|,
	},

	'cart template' => {
		message 	=> q|Cart Template|,
		lastUpdated	=> 0,
		context		=> q|a help title|,
	},

	'address book template' => {
		message 	=> q|Address Book Template|,
		lastUpdated	=> 0,
		context		=> q|a help title|,
	},

	'quantity help' => {
		message 	=> q|The number of this item that is purchased.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'item name help' => {
		message 	=> q|The name or title of the product.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'price help' => {
		message 	=> q|The amount this items costs to purchase.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'configuredTitle help' => {
		message 	=> q|The name of the item as configured for purchase.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'dateAdded help' => {
		message 	=> q|The date and time this item was added to the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'isUnique help' => {
		message 	=> q|A condition indicating whether this item is unique and therefore can only have a quantity of 1.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'quantityField help' => {
		message 	=> q|The field where the user may specify the quantity of the item they wish to purchase.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'isShippable help' => {
		message 	=> q|A condition indicating whether the item can have a shipping address attached to it.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'extendedPrice help' => {
		message 	=> q|The result of price multipled by quantity.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'removeButton help' => {
		message 	=> q|Clicking this button will remove the item from the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'item shipToButton help' => {
		message 	=> q|Clicking this button will set an alternate address as the destination of this item.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'shippingAddress help' => {
		message 	=> q|The HTML formatted address to ship to.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'error help' => {
		message 	=> q|If there are any problems the error message will be displayed here.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'formHeader help' => {
		message 	=> q|The top of the form.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'formFooter help' => {
		message 	=> q|The bottom of the form.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'continueShoppingButton help' => {
		message 	=> q|Clicking this button will take the user back to the site.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'updateButton help' => {
		message 	=> q|Clicking this button will apply the changes you made to the cart and recalculate all the prices.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'subtotalPrice help' => {
		message 	=> q|The price of all the items in the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'shippingPrice help' => {
        message     => q|Shipping price, formatted to two decimal places.|,
		lastUpdated	=> 1213146238,
		context		=> q|a help description|,
	},

	'tax help' => {
		message 	=> q|The price of tax on all the items in the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'hasShippingAddress help' => {
		message 	=> q|A condition indicating whether the user has already specified a shipping address. Shipping address is always required in order to calculate taxes.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'shippingOptions help' => {
		message 	=> q|A select list containing all the configured shipping options for this order.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'inShopCreditAvailable help' => {
		message 	=> q|The amount of in-shop credit the user has.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'inShopCreditDeduction help' => {
		message 	=> q|The amount of in-shop credit that has been applied to this order.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'totalPrice help' => {
		message 	=> q|The total checkout price of the cart as it stands currently.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'totalItems help' => {
		message 	=> q|The total number of items in the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'item url help' => {
		message 	=> q|The url to view this item as configured.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'items loop help' => {
		message 	=> q|A loop containing the variables of each item in the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'minicart template help' => {
		message 	=> q|The following variables are available in the template for the MiniCart macro.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'cart template help' => {
		message 	=> q|This template determines what the shopping cart looks like.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'address book template help' => {
		message 	=> q|This template determines what the address book will look like.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'who can manage help' => {
		message 	=> q|The group that has management rights over commerce.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'who can manage' => {
		message 	=> q|Who can manage?|,
		lastUpdated	=> 0,
		context		=> q|a setting|,
	},

	'address loop help' => {
		message 	=> q|A loop containing the list of addresses in this book and their management tools.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'address help' => {
		message 	=> q|An HTML formatted address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'editButton help' => {
		message 	=> q|A button that will allow the user to edit an existing address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'defaultButton help' => {
		message 	=> q|A button that will allow the user to set an address as a default.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'deleteButton help' => {
		message 	=> q|A button that will allow the user to delete an existing address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'useButton help' => {
		message 	=> q|A button that will allow the user to select an existing address for use on a form.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'addButton help' => {
		message 	=> q|A button that will allow the user to add a new address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'saveButton help' => {
		message 	=> q|The default save button for the form.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'address1Field help' => {
		message 	=> q|The field for the main address line.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'address2Field help' => {
		message 	=> q|The field for the secondary address line.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'address3Field help' => {
		message 	=> q|The field for the tertiary address line.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'address labelField help' => {
		message 	=> q|A field to contain the address label like 'home' or 'work'.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'address nameField help' => {
		message 	=> q|A field to contain the name of the person/company for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'name help' => {
		message 	=> q|The name of the person at this address.|,
		lastUpdated	=> 0,
		context		=> q|Help for the name template variable in the address book|,
	},

	'cityField help' => {
		message 	=> q|A field to contain the city for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'city help' => {
		message 	=> q|The city for this address.|,
		lastUpdated	=> 0,
		context		=> q|Help for the city template variable.|,
	},

	'stateField help' => {
		message 	=> q|A field to contain the state or province for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'state help' => {
		message 	=> q|The state or province for this address.|,
		lastUpdated	=> 0,
		context		=> q|Help for the address book template variable|,
	},

	'countryField help' => {
		message 	=> q|A field to contain the country for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'country help' => {
		message 	=> q|The country for this address.|,
		lastUpdated	=> 0,
		context		=> q|Help for the address book template variable, country.|,
	},

	'codeField help' => {
		message 	=> q|A field to contain the zip code or postal code for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'code help' => {
		message 	=> q|The postal, or zip code, for this address.|,
		lastUpdated	=> 0,
		context		=> q|Help for the address book template variable, code.|,
	},

	'phoneNumberField help' => {
		message 	=> q|A field to contain the phone number for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},

	'phoneNumber help' => {
		message 	=> q|A phone number for this address.|,
		lastUpdated	=> 0,
		context		=> q|Help for the address book template variable, phoneNumber.|,
	},

	'view cart' => {
		message 	=> q|View Cart|,
		lastUpdated	=> 0,
		context		=> q|a link label|,
	},

	'my purchases' => { 
		message => q|My Purchases|,
		lastUpdated => 0,
		context => q|a screen heading|
	},

	'my purchases template' => { 
		message => q|My Purchases Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'my purchases template help' => { 
		message => q|Which template should be used to display a user's order history?|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'my purchases detail template' => { 
		message => q|My Purchases Detail Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'my purchases detail template help' => { 
		message => q|Which template should be used to display a user's order history detail? An individual sale rather than the whole transaction list.|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'username' => { 
		message => q|User|,
		lastUpdated => 0,
		context => q|field label|
	},

	'tracking number' => { 
		message => q|Tracking #|,
		lastUpdated => 0,
		context => q|field label|
	},

	'order status' => { 
		message => q|Order Status|,
		lastUpdated => 0,
		context => q|field label|
	},

	'Shipped' => { 
		message => q|Shipped|,
		lastUpdated => 0,
		context => q|field label|
	},

	'NotShipped' => { 
		message => q|Not Shipped|,
		lastUpdated => 0,
		context => q|field label|
	},

	'Backordered' => { 
		message => q|Backordered|,
		lastUpdated => 0,
		context => q|field label|
	},

	'Cancelled' => { 
		message => q|Cancelled|,
		lastUpdated => 0,
		context => q|field label|
	},

	'vendors' => { 
		message => q|Vendors|,
		lastUpdated => 0,
		context => q|admin function label|
	},

    'vendor payouts' => {
        message => q|Vendor payouts|,
        lastUpdated => 0,
        context => q|admin function label|
    },

	'update' => { 
		message => q|Update|,
		lastUpdated => 0,
		context => q|button label|
	},

	'refund' => { 
		message => q|Refund|,
		lastUpdated => 0,
		context => q|button label|
	},

	'date' => { 
		message => q|Date|,
		lastUpdated => 0,
		context => q|field label|
	},

	'add credit message' => { 
		message => q|%s was added to %s's in-shop credit account, for a total credit of %s.|,
		lastUpdated => 0,
		context => q|field label|
	},

	'current credit message' => { 
		message => q|%s has a total credit of %s.|,
		lastUpdated => 0,
		context => q|field label|
	},

	'amount' => { 
		message => q|Amount|,
		lastUpdated => 1213632324,
		context => q|field label for money|
	},

	'notes' => { 
		message => q|Notes|,
		lastUpdated => 0,
		context => q|field label|
	},

	'manage' => { 
		message => q|Manage|,
		lastUpdated => 0,
		context => q|field label|
	},

	'order number' => { 
		message => q|Order #|,
		lastUpdated => 0,
		context => q|field label|
	},

	'status code' => { 
		message => q|Status Code|,
		lastUpdated => 0,
		context => q|field label|
	},

	'status message' => { 
		message => q|Status Message|,
		lastUpdated => 0,
		context => q|field label|
	},

	'Status' => { 
		message => q|Status|,
		lastUpdated => 0,
		context => q|Whether a transaction was successful, or not.|
	},

	'payment method' => { 
		message => q|Payment Method|,
		lastUpdated => 0,
		context => q|field label|
	},

	'shipping method' => { 
		message => q|Shipping Method|,
		lastUpdated => 0,
		context => q|field label|
	},

	'shipping amount' => { 
		message => q|Shipping Amount|,
		lastUpdated => 0,
		context => q|field label|
	},

	'add shipper' => { 
		message => q|Add Shipping Method|,
		lastUpdated => 0,
		context => q|button in shipping manager|
	},

	'address book template' => { 
		message => q|Address Book Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'edit address template' => { 
		message => q|Edit Address Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'edit address template help' => { 
		message => q|This template determines what the address editor will look like.|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'select gateway template' => { 
		message => q|Select Gateway Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'select gateway template help' => { 
		message => q|This template is the template for the Select Payment Gateway step.|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'transactions' => { 
		message => q|Transactions|,
		lastUpdated => 0,
		context => q|admin function label|
	},

	'payment methods' => { 
		message => q|Payment Methods|,
		lastUpdated => 0,
		context => q|admin function label|
	},

	'shipping methods' => { 
		message => q|Shipping Methods|,
		lastUpdated => 0,
		context => q|admin function label|
	},

	'taxes' => { 
		message => q|Taxes|,
		lastUpdated => 0,
		context => q|admin function label|
	},

	'shop settings' => { 
		message => q|Shop Settings|,
		lastUpdated => 0,
		context => q|admin function label|
	},

	'products' => { 
		message => q|Products|,
		lastUpdated => 0,
		context => q|admin function label|
	},

	'is a required field' => { 
		message => q|%s is a required field.|,
		lastUpdated => 0,
		context => q|an error message|
	},

	'label' => { 
		message => q|Label|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'label help' => { 
		message => q|eg: 'Home' or 'Work'|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'name' => { 
		message => q|Name|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'firstName' => { 
		message => q|First Name|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'lastName' => { 
		message => q|Last Name|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'address' => { 
		message => q|Address|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'city' => { 
		message => q|City|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'state' => { 
		message => q|State / Province|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'code' => { 
		message => q|Postal / Zip Code|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'available' => { 
		message => q|Available|,
		lastUpdated => 0,
		context => q|a label in the cart|
	},

	'in shop credit' => { 
		message => q|In-Shop Credit|,
		lastUpdated => 0,
		context => q|a label in the cart|
	},

	'in shop credit used' => { 
		message => q|In-Shop Credit Used|,
		lastUpdated => 0,
		context => q|a label in the transaction|
	},

	'country' => { 
		message => q|Country|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'phone number' => { 
		message => q|Phone Number|,
		lastUpdated => 0,
		context => q|a label in the address editor|
	},

	'date created' => { 
		message => q|Date Created|,
		lastUpdated => 0,
		context => q|a label in the vendor manager|
	},

	'add a new address' => { 
		message => q|Add A New Address|,
		lastUpdated => 0,
		context => q|a button in the address book|
	},

	'add a vendor' => { 
		message => q|Add A Vendor|,
		lastUpdated => 0,
		context => q|a button in the vendor manager|
	},

	'delete' => { 
		message => q|Delete|,
		lastUpdated => 0,
		context => q|a button in the address book|
	},

	'default' => { 
		message => q|Set Default|,
		lastUpdated => 0,
		context => q|a button in the address book|
	},

	'edit' => { 
		message => q|Edit|,
		lastUpdated => 0,
		context => q|a button in the address book|
	},

	'use this address' => { 
		message => q|Use This Address|,
		lastUpdated => 0,
		context => q|a button in the address book|
	},

	'too many of this item' => { 
		message => q|Can't add that many %s to your cart.|,
		lastUpdated => 0,
		context => q|an error message|
	},

	'subtotal' => { 
		message => q|Subtotal|,
		lastUpdated => 0,
		context => q|a summary heading in the cart|
	},

	'coupon' => { 
		message => q|Coupon|,
		lastUpdated => 0,
		context => q|a summary heading in the cart|
	},

	'tax' => { 
		message => q|Tax|,
		lastUpdated => 0,
		context => q|a summary heading in the cart|
	},

	'total' => { 
		message => q|Total|,
		lastUpdated => 0,
		context => q|a summary heading in the cart|
	},

	'shipping' => { 
		message => q|Shipping|,
		lastUpdated => 0,
		context => q|a summary heading in the cart|
	},

	'not applicable' => { 
		message => q|N/A|,
		lastUpdated => 0,
		context => q|shipping not possible on this item because it's not a physical good|
	},

	'item' => { 
		message => q|Item|,
		lastUpdated => 0,
		context => q|a column heading label in the shopping cart|
	},

	'price' => { 
		message => q|Price|,
		lastUpdated => 0,
		context => q|a column heading label in the shopping cart|
	},

	'quantity' => { 
		message => q|Quantity|,
		lastUpdated => 0,
		context => q|a column heading label in the shopping cart|
	},

	'extended price' => { 
		message => q|Extended Price|,
		lastUpdated => 0,
		context => q|a column heading label in the shopping cart|
	},

	'per item shipping' => { 
		message => q|Per Item Shipping|,
		lastUpdated => 0,
		context => q|a column heading label in the shopping cart|
	},

	'remove button' => { 
		message => q|Remove|,
		lastUpdated => 0,
		context => q|a button a user clicks on to remove an item from the cart|
	},

	'company url' => { 
		message => q|Company URL|,
		lastUpdated => 0,
		context => q|a field in the vendor screen|
	},
	
	'checkout button' => { 
		message => q|Checkout|,
		lastUpdated => 0,
		context => q|a button the user clicks on to proceed to payment options|
	},

	'choose shipping button' => { 
		message => q|Choose Address &amp; Checkout|,
		lastUpdated => 1224818677,
		context => q|a button the user clicks on to choose shipping information and tax calculation|
	},

	'update cart button' => { 
		message => q|Update Cart|,
		lastUpdated => 0,
		context => q|a button the user clicks on to apply changes to the cart|
	},

	'continue shopping button' => { 
		message => q|Continue Shopping|,
		lastUpdated => 0,
		context => q|a button the user clicks on to go back to shopping after viewing the cart|
	},

    'empty cart' => { 
		message => q|There are no items currently in your cart.|,
		lastUpdated => 0,
		context => q|a message to the user that the cart is empty|
	},


	'shop' => { 
		message => q|Shop|,
		lastUpdated => 0,
		context => q|the title of all commerce related stuff in the admin console|
	},

	'ship to button' => { 
		message => q|Ship To|,
		lastUpdated => 0,
		context => q|a button the user clicks on to set shipping information|
	},

	'Special shipping' => { 
		message => q|Special shipping|,
		lastUpdated => 0,
		context => q|a button the user clicks on to set shipping information on an item|
	},

	'shipping address' => { 
		message => q|Shipping Address|,
		lastUpdated => 0,
		context => q|Label in view transaction|,
	},

	'payment address' => { 
		message => q|Payment Address|,
		lastUpdated => 0,
		context => q|Label in view transaction|,
	},

	'transaction id' => { 
		message => q|Transaction ID|,
		lastUpdated => 0,
		context => q|Label in view transaction|,
	},

	'add to cart' => {
		message => q|Add to cart|,
		lastUpdated => 1211080800,
		context => q|The label for the add to cart button.|
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

    'address1 help' => {
        message => q|The first address line.|,
        lastUpdated => 1213121298,
        context => q|Description of a template variable for the edit address template|,
    },

    'address2 help' => {
        message => q|The second address line.|,
        lastUpdated => 1213121298,
        context => q|Description of a template variable for the edit address template|,
    },

    'address3 help' => {
        message => q|The third address line|,
        lastUpdated => 1213121298,
        context => q|Description of a template variable for the edit address template|,
    },

    'addresses loop help' => {
        message => q|A loop containing all addresses in this address book|,
        lastUpdated => 1213121298,
        context => q|Description of a template variable for the edit address template|,
    },

    'viewDetailURL' => {
        message => q|A URL for viewing more details about the user's transaction.|,
        lastUpdated => 1213121298,
        context => q|Template variable for email receipt template|,
    },

    'amount help' => {
        message => q|The total amount of this transaction, formatted to two decimal places.|,
        lastUpdated => 1213121298,
        context => q|Template variable for email receipt template|,
    },

    'taxes help' => {
        message => q|Taxes for this transaction, formatted to two decimal places.|,
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

    'username help' => {
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
        message => q|The country from the shipping address.|,
        lastUpdated => 1216654340,
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
        message => q|The country from the payment address.|,
        lastUpdated => 1216654356,
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

    'price help' => {
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
        message => q|The country from the shipping address for this item.|,
        lastUpdated => 1216787074,
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

    'manage my purchases template' => {
        message => q|Manage My Purchases Template|,
        lastUpdated => 1213143434,
        context => q||,
    },

    'manage my purchases template help' => {
        message => q|This template displays partial information about transactions to the user.|,
        lastUpdated => 1213143433,
        context => q||,
    },

    'view my purchases template' => {
        message => q|View My Purchases Template|,
        lastUpdated => 1213137846,
        context => q||,
    },

    'view my purchases template help' => {
        message => q|This template displays detailed information about transactions to the user.|,
        lastUpdated => 1213137846,
        context => q||,
    },

    'notice' => {
        message => q|Any message from the system to be displayed to the user.|,
        lastUpdated => 1213137846,
        context => q|Template variable for email receipt template|,
    },

    'cancelRecurringUrl' => {
        message => q|A URL that allows the user to cancel a recurring transaction.|,
        lastUpdated => 1213137846,
        context => q|Template variable for email receipt template|,
    },

    'add payment method' => {
        message => q|Add a payment method|,
        lastUpdated => 0,
        context => q|The label of the button that will add a new payment method|,
    },

    'login message' => {
        message => q|You must log in to check out. To login click <a href="%s"> here</a>.|,
        lastUpdated => 0,
        context => q|Fallback message that vistors will see if they try to check out and the redirect to the login page is not working for some reason.|,
    },

    'choose payment gateway message' => {
        message => q|How would you like to pay?|,
        lastUpdated => 42,
        context => q|Message asking the user to choose one of the available payment options.|,
    },

    'import tax' => {
        message => q|Import Taxes|,
        lastUpdated => 1217125374,
        context => q|Label for the manage tax screen|,
    },

    'export tax' => {
        message => q|Export Taxes|,
        lastUpdated => 1217125391,
        context => q|Label for the manage tax screen|,
    },

    'isCashier' => {
        message => q|A boolean which is true if the current user can be a cashier inside the Shop.|,
        lastUpdated => 1227495334,
        context => q|template variable for Cart template|,
    },

    'posLookupForm' => {
        message => q|A form where a cashier can lookup a user by email address.|,
        lastUpdated => 1227495334,
        context => q|template variable for Cart template|,
    },

    'posUsername' => {
        message => q|The name of the user making the POS transaction.|,
        lastUpdated => 1227495334,
        context => q|template variable for Cart template|,
    },

    'posUserId' => {
        message => q|The userId of the user making the POS transaction.|,
        lastUpdated => 1227495334,
        context => q|template variable for Cart template|,
    },

    'cart checkout minimum' => {
        message => q|Minimum checkout amount|,
        lastUpdated => 0,
        context => q|shop setting label|,
    },

    'cart checkout minimum help' => {
        message => q|Use this setting to require a minimum cart value to allow users to check out.|,
        lastUpdated => 0,
        context => q|shop setting hover help|,
    },

    'required minimum order amount' => {
        message => q|Minimum order:|,
        lastUpdated => 0,
        context => q|message that is displayed in the cart view screen|,
    },

    'schedule all button' => {
        message => q|Schedule all|,
        lastUpdated => 0,
        context => 'Label for the schedule all button in the vendor payouts manager',
    },

    'deschedule all button' => {
        message => q|Deschedule all|,
        lastUpdated => 0,
        context => 'Label for the deschedule all button in the vendor payouts manager',
    },

    'submit scheduled payouts button' => {
        message => q|Submit Scheduled Payouts|,
        lastUpdated => 0,
        context => 'Label for the submit scheduled payouts button in the vendor payouts manager',
    },
   
    'vendor id'  => {
        message => q|Vendor ID|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'vendor name'  => {
        message => q|Name|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'scheduled payout amount'  => {
        message => q|Scheduled for payout|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'not scheduled payout amount'  => {
        message => q|Not scheduled for payout|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'vp select vendor' => {
        message => q|Please select a vendor from the list above to manage individual payouts.|,
        lastUpdated => 0,
        context => q|Message in the vendor payouts manager when no vendor has been selected.|,
    },

    'vp vendors' => {
        message => q|Vendors|,
        lastUpdated => 0,
        context => q|Label for the vendors section of the vendor payouts manager|,
    },

    'vp payouts' => {
        message => q|Payouts|,
        lastUpdated => 0,
        context => q|Label for the vendors section of the vendor payouts manager|,
    },
   
    'vp item id'  => {
        message => q|Item ID|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'vp item title'  => {
        message => q|Item name|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'vp item price'  => {
        message => q|Price|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },
    'vp item quantity'  => {
        message => q|Qty|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'vp item payout amount'  => {
        message => q|Payout amount|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'vp item payout status'  => {
        message => q|Payout status|,
        lastUpdated => 0,
        context => q|Table heading in the vendor payout manager.|,
    },

    'copy from home address' => {
        message => q|Copy home address from profile|,
        lastUpdated => 0,
        context => q|Button label in the edit address screen.|,
    },

    'copy from work address' => {
        message => q|Copy work address from profile|,
        lastUpdated => 0,
        context => q|Button label in the edit address screen.|,
    },

    'group label' => {
        message => q|Label|,
        lastUpdated => 0,
        context => q|Label in the EU tax manager|,
    },

    'group rate' => {
        message => q|Tax rate|,
        lastUpdated => 0,
        context => q|Label in the EU tax manager|,
    },

    'No shipping plugins configured' => {
        message => q|No shipping plugins configured.  Please notify the site adminstrator.|,
        lastUpdated => 0,
        context => q|Error message in the cart|,
    },

    'No shippers' => {
        message => q|No shipping drivers are configured.  Users will not be able to checkout until at least one is configured.|,
        lastUpdated => 0,
        context => q|Error message in the manage ship driver screen.|,
    },

    'Choose a shipping method' => {
        message => q|Choose a shipping method|,
        lastUpdated => 0,
        context => q|Label to make the user choose a shipping method|,
    },

    'Choose a shipping method and update the cart to checkout' => {
        message => q|Choose a shipping method and update the cart to checkout|,
        lastUpdated => 0,
        context => q|Label to make the user choose a shipping method|,
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

	'Success' => { 
		message => q|Success|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'Failed' => { 
		message => q|Failure|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'Billing Address' => { 
		message => q|Billing Address|,
		lastUpdated => 0,
		context => q|template label for the cart|
	},

	'Shipping Address' => { 
		message => q|Shipping Address|,
		lastUpdated => 0,
		context => q|template label for the cart|
	},

	'use same shipping as billing' => { 
		message => q|Use the same shipping address as billing address.|,
		lastUpdated => 0,
		context => q|template label for the cart|
	},

	'Add new address' => { 
		message => q|Add new address|,
		lastUpdated => 0,
		context => q|form label for the cart.  Allows user to build a new address.|
	},

	'Update this address' => { 
		message => q|Update this address|,
		lastUpdated => 0,
		context => q|form label for the cart.  Allows user to build a new address.|
	},

	'Choose a payment method' => { 
		message => q|Choose a payment method|,
		lastUpdated => 0,
		context => q|form label for the cart.  Allows user to choose a payment method.  Bart Jol for Minister in 2012!|
	},

	'shippableItemsInCart' => { 
		message => q|A boolean which will be true if any item in the cart requires shipping.|,
		lastUpdated => 0,
		context => q|form label for the cart.  Allows user to choose a payment method.  Bart Jol for Minister in 2012!|
	},

};

1;
