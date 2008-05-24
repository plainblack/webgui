package WebGUI::i18n::English::Shop;

use strict;

our $I18N = { 
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
	
	'address book template' => {
		message 	=> q|Address Book Template|,
		lastUpdated	=> 0,
		context		=> q|a help title|,
	},
	
	'edit address template' => {
		message 	=> q|Edit Address Template|,
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
	
	'checkoutButton help' => {
		message 	=> q|The button the user pushes to choose a payment method.|,
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
	
	'chooseShippingButton help' => {
		message 	=> q|Clicking this button will let the user pick a shipping address from the address book.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'shipToButton help' => {
		message 	=> q|Does the same as the chooseShippingButton.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'subtotalPrice help' => {
		message 	=> q|The price of all the items in the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'shippingPrice help' => {
		message 	=> q|The price of shipping on all the items in the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'tax help' => {
		message 	=> q|The price of tax on all the items in the cart.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'hasShippingAddress help' => {
		message 	=> q|A condition indicating whether the the user has already specified a shipping address. Shipping address is always required in order to calculate taxes.|,
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
		message 	=> q|The following variables are available in the shopping cart template.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'address book template help' => {
		message 	=> q|The following variables are available for templating the Address Book.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'address book template help' => {
		message 	=> q|The following variables are available from in the address book template.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
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
	
	'edit address template help' => {
		message 	=> q|The following variables are available in the edit address template.|,
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
	
	'cityField help' => {
		message 	=> q|A field to contain the city for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'stateField help' => {
		message 	=> q|A field to contain the state or province for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'countryField help' => {
		message 	=> q|A field to contain the country for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'codeField help' => {
		message 	=> q|A field to contain the zip code or postal code for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'phoneNumberField help' => {
		message 	=> q|A field to contain the phone number for this address.|,
		lastUpdated	=> 0,
		context		=> q|a help description|,
	},
	
	'view cart' => {
		message 	=> q|View Cart|,
		lastUpdated	=> 0,
		context		=> q|a link label|,
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

	'amount' => { 
		message => q|Amount|,
		lastUpdated => 0,
		context => q|field label|
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

	'shopping cart template' => { 
		message => q|Cart Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'shopping cart template help' => { 
		message => q|Choose the template that you want used to render the shopping cart.|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'address book template' => { 
		message => q|Address Book Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'address book template help' => { 
		message => q|Choose the template you want used to render the address book.|,
		lastUpdated => 0,
		context => q|commerce setting help|
	},

	'edit address template' => { 
		message => q|Edit Address Template|,
		lastUpdated => 0,
		context => q|commerce setting|
	},

	'edit address template help' => { 
		message => q|Choose the template you want used to render the address edit form.|,
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

	'checkout button' => { 
		message => q|Checkout|,
		lastUpdated => 0,
		context => q|a button the user clicks on to proceed to payment options|
	},

	'choose shipping button' => { 
		message => q|Choose Shipping Address|,
		lastUpdated => 0,
		context => q|a button the user clicks on to choose shipping information|
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

};

1;
