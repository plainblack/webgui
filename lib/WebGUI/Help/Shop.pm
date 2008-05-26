package WebGUI::Help::Shop;

use strict; 


our $HELP = { 
	'minicart template' => {	
		title 		=> 'minicart template', 
		body 		=> 'minicart template help',	
		isa 		=> [],
		fields 		=> [],
		variables 	=> [
			{
				name 		=> "items",
				description => "items loop help",
				required 	=> 1,
				variables 	=> [
					{
						name		=> "name",
						description => "item name help",
						required	=> 1,
					},
					{
						name		=> "quantity",
						description => "quantity help",
					},
					{
						name		=> "price",
						description => "price help",
					},
					{
						name		=> "url",
						description => "item url help",
					},
				],
			},
			{
				name		=> "totalPrice",
				description	=> "totalPrice help",
			},
			{
				name		=> "totalItems",
				description	=> "totalItems help",
			},
		],
		related 	=> [  
			{
				tag 		=> 'cart template',
				namespace 	=> 'Shop',
			},
		],
	},
	'cart template' => {	
		title 		=> 'cart template', 
		body 		=> 'cart template help',	
		isa 		=> [],
		fields 		=> [],
		variables 	=> [
			{
				name 		=> "items",
				description => "items loop help",
				required 	=> 1,
				variables 	=> [
					{
						name		=> "configuredTitle",
						description => "configuredTitle help",
						required	=> 1,
					},
					{
						name		=> "quantity",
						description => "quantity help",
					},
					{
						name		=> "dateAdded",
						description => "dateAdded help",
					},
					{
						name		=> "url",
						description => "item url help",
					},
					{
						name		=> "quantityField",
						description => "quantityField help",
						required	=> 1,
					},
					{
						name		=> "isUnique",
						description => "isUnique help",
					},
					{
						name		=> "isShippable",
						description => "isShippable help",
					},
					{
						name		=> "extendedPrice",
						description => "extendedPrice help",
					},
					{
						name		=> "price",
						description => "price help",
					},
					{
						name		=> "removeButton",
						description => "removeButton help",
						required	=> 1,
					},
					{
						name		=> "shipToButton",
						description => "item shipToButton help",
					},
					{
						name		=> "shippingAddress",
						description => "shippingAddress help",
					},
				],
			},
			{
				name		=> "error",
				description	=> "error help",
				required	=> 1,
			},
			{
				name		=> "formHeader",
				description	=> "formHeader help",
				required	=> 1,
			},
			{
				name		=> "formFooter",
				description	=> "formFooter help",
				required	=> 1,
			},
			{
				name		=> "checkoutButton",
				description	=> "checkoutButton help",
				required	=> 1,
			},
			{
				name		=> "updateButton",
				description	=> "updateButton help",
				required	=> 1,
			},
			{
				name		=> "continueShoppingButton",
				description	=> "continueShoppingButton help",
			},
			{
				name		=> "chooseShippingButton",
				description	=> "chooseShippingButton help",
				required	=> 1,
			},
			{
				name		=> "shipToButton",
				description	=> "shipToButton help",
			},
			{
				name		=> "subtotalPrice",
				description	=> "subtotalPrice help",
			},
			{
				name		=> "shippingPrice",
				description	=> "shippingPrice help",
			},
			{
				name		=> "tax",
				description	=> "tax help",
			},
			{
				name		=> "hasShippingAddress",
				description	=> "hasShippingAddress help",
			},
			{
				name		=> "shippingAddress",
				description	=> "shippingAddress help",
			},
			{
				name		=> "shippingOptions",
				description	=> "shippingOptions help",
				required	=> 1,
			},
			{
				name		=> "totalPrice",
				description	=> "totalPrice help",
				required	=> 1,
			},
			{
				name		=> "inShopCreditAvailable",
				description	=> "inShopCreditAvailable help",
			},
			{
				name		=> "inShopCreditDeduction",
				description	=> "inShopCreditDeduction help",
			},
		],
		related 	=> [  
			{
				tag 		=> 'minicart template',
				namespace 	=> 'Shop',
			},
			{
				tag 		=> 'address book template',
				namespace 	=> 'Shop',
			},
		],
	},
	'address book template' => {	
		title 		=> 'address book template', 
		body 		=> 'address book template help',	
		isa 		=> [],
		fields 		=> [],
		variables 	=> [
			{
				name 		=> "addresses",
				description => "addresses loop help",
				required 	=> 1,
				variables 	=> [
					{
						name		=> "address",
						description => "address help",
						required 	=> 1,
					},
					{
						name		=> "editButton",
						description => "editButton help",
						required 	=> 1,
					},
					{
						name		=> "deleteButton",
						description => "deleteButton help",
						required 	=> 1,
					},
					{
						name		=> "useButton",
						description => "useButton help",
						required 	=> 1,
					},
				],
			},
			{
				name		=> "addButton",
				description	=> "addButton help",
				required	=> 1,
			},
		],
		related 	=> [  
			{
				tag 		=> 'cart template',
				namespace 	=> 'Shop',
			},
			{
				tag 		=> 'edit address template',
				namespace 	=> 'Shop',
			},
		],
	},

	'edit address template' => {	
		title 		=> 'edit address template', 
		body 		=> 'edit address template help',	
		isa 		=> [],
		fields 		=> [],
		variables 	=> [
			{
				name 		=> "address1",
				description => "address1 help",
			},
			{
				name 		=> "address2",
				description => "address2 help",
			},
			{
				name 		=> "address3",
				description => "address3 help",
			},
			{
				name 		=> "state",
				description => "state help",
			},
			{
				name 		=> "city",
				description => "city help",
			},
			{
				name 		=> "label",
				description => "label help",
			},
			{
				name 		=> "name",
				description => "name help",
			},
			{
				name 		=> "country",
				description => "country help",
			},
			{
				name 		=> "code",
				description => "code help",
			},
			{
				name 		=> "phoneNumber",
				description => "phoneNumber help",
			},
			{
				name 		=> "error",
				description => "error help",
				required 	=> 1,
			},
			{
				name		=> "formHeader",
				description	=> "formHeader help",
				required	=> 1,
			},
			{
				name		=> "formFooter",
				description	=> "formFooter help",
				required	=> 1,
			},
			{
				name		=> "saveButton",
				description	=> "saveButton help",
				required	=> 1,
			},
			{
				name		=> "address1Field",
				description	=> "address1Field help",
				required	=> 1,
			},
			{
				name		=> "address2Field",
				description	=> "address2Field help",
				required	=> 1,
			},
			{
				name		=> "address3Field",
				description	=> "address3Field help",
				required	=> 1,
			},
			{
				name		=> "labelField",
				description	=> "address labelField help",
				required	=> 1,
			},
			{
				name		=> "nameField",
				description	=> "addres nameField help",
				required	=> 1,
			},
			{
				name		=> "cityField",
				description	=> "cityField help",
				required	=> 1,
			},
			{
				name		=> "stateField",
				description	=> "stateField help",
				required	=> 1,
			},
			{
				name		=> "countryField",
				description	=> "countryField help",
				required	=> 1,
			},
			{
				name		=> "codeField",
				description	=> "codeField help",
				required	=> 1,
			},
			{
				name		=> "phoneNumberField",
				description	=> "phoneNumberField help",
				required	=> 1,
			},
		],
		related 	=> [  
			{
				tag 		=> 'address book template',
				namespace 	=> 'Shop',
			},
		],
	},
};

1;  
