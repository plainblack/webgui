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
						name		=> "removeBox",
						description => "removeBox help",
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
						name		=> "itemAddressChooser",
						description => "itemAddressChooser help",
					},
					{
						name		=> "shippingAddress",
						description => "shippingAddress help",
					},
				],
			},
			{
				name		=> "message",
				description	=> "message help",
				required	=> 1,
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
				name		=> "updateButton",
				description	=> "updateButton help",
				required	=> 1,
			},
			{
				name		=> "continueShoppingButton",
				description	=> "continueShoppingButton help",
			},
			{
				name		=> "minimumCartAmount",
				description	=> "minimumCartAmount help",
			},
			{
				name		=> "subtotalPrice",
				description	=> "subtotalPrice help",
			},
			{
				name		=> "shippingAddressChooser",
				description	=> "shippingAddressChooser help",
			},
			{
				name		=> "billingAddressChooser",
				description	=> "billingAddressChooser help",
			},
			{
				name		=> "sameShippingAsBilling",
				description	=> "sameShippingAsBilling help",
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
				name		=> "userIsVisitor",
				description	=> "userIsVisitor help",
			},
			{
				name		=> "shippableItemsInCart",
			},
			{
				name		=> "hasShippingAddress",
				description	=> "hasShippingAddress help",
			},
			{
				name		=> "shippingOptions",
				description	=> "shippingOptions help",
				required	=> 1,
			},
			{
				name		=> "paymentOptions",
				description	=> "paymentOptions help",
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
            {
                name		=> "isCashier",
            },
            {
                name		=> "posLookupForm",
            },
            {
                name		=> "posUsername",
            },
            {
                name		=> "posUserId",
            },
			{
				name		=> "loginFormHeader",
				description	=> "loginFormHeader help",
                required    => 1,
			},
			{
				name		=> "loginFormFooter",
				description	=> "loginFormFooter help",
                required    => 1,
			},
			{
				name		=> "loginFormUsername",
				description	=> "loginFormUsername help",
                required    => 1,
			},
			{
				name		=> "loginFormPassword",
				description	=> "loginFormPassword help",
                required    => 1,
			},
			{
				name		=> "loginFormButton",
				description	=> "loginFormButton help",
                required    => 1,
			},
			{
				name		=> "registerLink",
				description	=> "registerLink help",
                required    => 1,
			},
			{
				name		=> "billing_address1Field",
				description	=> "address1Field help",
				required	=> 1,
			},
			{
				name		=> "billing_address2Field",
				description	=> "address2Field help",
				required	=> 1,
			},
			{
				name		=> "billing_address3Field",
				description	=> "address3Field help",
				required	=> 1,
			},
			{
				name		=> "billing_labelField",
				description	=> "address labelField help",
				required	=> 1,
			},
			{
				name		=> "billing_nameField",
				description	=> "address nameField help",
				required	=> 1,
			},
			{
				name		=> "billing_cityField",
				description	=> "cityField help",
				required	=> 1,
			},
			{
				name		=> "billing_stateField",
				description	=> "stateField help",
				required	=> 1,
			},
			{
				name		=> "billing_countryField",
				description	=> "countryField help",
				required	=> 1,
			},
			{
				name		=> "billing_codeField",
				description	=> "codeField help",
				required	=> 1,
			},
			{
				name		=> "billing_phoneNumberField",
				description	=> "phoneNumberField help",
				required	=> 1,
			},
			{
				name		=> "billing_emailField",
				description	=> "emailField help",
				required	=> 1,
			},
			{
				name		=> "shipping_address1Field",
				description	=> "address1Field help",
				required	=> 1,
			},
			{
				name		=> "shipping_address2Field",
				description	=> "address2Field help",
				required	=> 1,
			},
			{
				name		=> "shipping_address3Field",
				description	=> "address3Field help",
				required	=> 1,
			},
			{
				name		=> "shipping_labelField",
				description	=> "address labelField help",
				required	=> 1,
			},
			{
				name		=> "shipping_nameField",
				description	=> "address nameField help",
				required	=> 1,
			},
			{
				name		=> "shipping_cityField",
				description	=> "cityField help",
				required	=> 1,
			},
			{
				name		=> "shipping_stateField",
				description	=> "stateField help",
				required	=> 1,
			},
			{
				name		=> "shipping_countryField",
				description	=> "countryField help",
				required	=> 1,
			},
			{
				name		=> "shipping_codeField",
				description	=> "codeField help",
				required	=> 1,
			},
			{
				name		=> "shipping_phoneNumberField",
				description	=> "phoneNumberField help",
				required	=> 1,
			},
			{
				name		=> "shipping_emailField",
				description	=> "emailField help",
				required	=> 1,
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
						name		=> "defaultButton",
						description => "defaultButton help",
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
				name 		=> "organization",
				description => "organization help",
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
				description	=> "address nameField help",
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
			{
				name		=> "emailField",
				description	=> "emailField help",
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

    'manage my purchases template' => {    
        title     => 'manage my purchases template', 
        body      => 'manage my purchases template help',    
        isa       => [],
        fields    => [],
        variables => [
            {
                name        => 'viewDetailURL',
            },
            {
                name        => 'amount',
            },
            {
                name        => 'transactionId',
            },
            {
                name        => 'originatingTransactionId',
            },
            {
                name        => 'isSuccessful',
            },
            {
                name        => 'orderNumber',
            },
            {
                name        => 'transactionCode',
            },
            {
                name        => 'statusCode',
            },
            {
                name        => 'statusMessage',
            },
            {
                name        => 'userId',
            },
            {
                name        => 'username',
                description => 'username help',
            },
            {
                name        => 'shopCreditDeduction',
            },
            {
                name        => 'shippingAddressId',
            },
            {
                name        => 'shippingAddressName',
            },
            {
                name        => 'shippingAddress1',
            },
            {
                name        => 'shippingAddress2',
            },
            {
                name        => 'shippingAddress3',
            },
            {
                name        => 'shippingAddressCity',
            },
            {
                name        => 'shippingAddressState',
            },
            {
                name        => 'shippingAddressCountry',
            },
            {
                name        => 'shippingAddressCode',
            },
            {
                name        => 'shippingAddressPhoneNumber',
            },
            {
                name        => 'shippingDriverId',
            },
            {
                name        => 'shippingDriverLabel',
            },
            {
                name        => 'paymentAddressId',
            },
            {
                name        => 'paymentAddress1',
            },
            {
                name        => 'paymentAddress2',
            },
            {
                name        => 'paymentAddress3',
            },
            {
                name        => 'paymentAddressCity',
            },
            {
                name        => 'paymentAddressState',
            },
            {
                name        => 'paymentAddressCountry',
            },
            {
                name        => 'paymentAddressCode',
            },
            {
                name        => 'paymentAddressPhoneNumber',
            },
            {
                name        => 'dateOfPurchase',
            },
            {
                name        => 'isRecurring',
            },
            {
                name        => 'notes',
            },
        ],
        related     => [  
        ],
    },

    'view my purchases template' => {    
        title     => 'view my purchases template', 
        body      => 'view my purchases template help',    
        isa       => [],
        fields    => [],
        variables => [
            {
                name        => 'notice',
                required    => 1,
            },
            {
                name        => 'cancelRecurringUrl',
                required    => 1,
            },
            {
                name        => 'amount',
                description => 'amount help',
            },
            {
                name        => 'taxes',
                description => 'taxes help',
            },
            {
                name        => "inShopCreditDeduction",
                description => "inShopCreditDeduction help",
            },
            {
                name        => 'shippingPrice',
                description => 'shippingPrice help',
            },
            {
                name        => 'shippingAddress',
                description => "shippingAddress help",
            },
            {
                name        => 'paymentAddress',
            },
            {
                name        => 'items',
                variables   => [
                    {
                        name        => 'viewItemUrl',
                    },
                    {
                        name        => 'price',
                        description => 'price help',
                    },
                    {
                        name        => 'itemShippingAddress',
                    },
                    {
                        name        => 'orderStatus',
                    },
                    {
                        name        => 'itemId',
                    },
                    {
                        name        => 'transactionId',
                        description => 'item transactionId',
                    },
                    {
                        name        => 'assetId',
                        description => 'item assetId',
                    },
                    {
                        name        => 'configuredTitle',
                    },
                    {
                        name        => 'options',
                        description => 'item options',
                    },
                    {
                        name        => 'shippingAddressId',
                        description => 'item shippingAddressId',
                    },
                    {
                        name        => 'shippingName',
                        description => 'item shippingName',
                    },
                    {
                        name        => 'shippingAddress1',
                        description => 'item shippingAddress1',
                    },
                    {
                        name        => 'shippingAddress2',
                        description => 'item shippingAddress2',
                    },
                    {
                        name        => 'shippingAddress3',
                        description => 'item shippingAddress3',
                    },
                    {
                        name        => 'shippingAddressCity',
                        description => 'item shippingAddressCity',
                    },
                    {
                        name        => 'shippingAddressState',
                        description => 'item shippingAddressState',
                    },
                    {
                        name        => 'shippingAddressCountry',
                        description => 'item shippingAddressCountry',
                    },
                    {
                        name        => 'shippingAddressCode',
                        description => 'item shippingAddressCode',
                    },
                    {
                        name        => 'shippingAddressPhoneNumber',
                        description => 'item shippingAddressPhoneNumber',
                    },
                    {
                        name        => 'lastUpdated',
                        description => 'item lastUpdated',
                    },
                    {
                        name        => 'quantity',
                        description => 'item quantity',
                    },
                    {
                        name        => 'price',
                        description => 'item price',
                    },
                    {
                        name        => 'vendorId',
                        description => 'item vendorId',
                    },
                ],
            },
            {
                name        => 'transactionId',
            },
            {
                name        => 'originatingTransactionId',
            },
            {
                name        => 'isSuccessful',
            },
            {
                name        => 'orderNumber',
            },
            {
                name        => 'transactionCode',
            },
            {
                name        => 'statusCode',
            },
            {
                name        => 'statusMessage',
            },
            {
                name        => 'userId',
            },
            {
                name        => 'username',
                description => 'username help',
            },
            {
                name        => 'shopCreditDeduction',
            },
            {
                name        => 'shippingAddressId',
            },
            {
                name        => 'shippingAddressName',
            },
            {
                name        => 'shippingAddress1',
            },
            {
                name        => 'shippingAddress2',
            },
            {
                name        => 'shippingAddress3',
            },
            {
                name        => 'shippingAddressCity',
            },
            {
                name        => 'shippingAddressState',
            },
            {
                name        => 'shippingAddressCountry',
            },
            {
                name        => 'shippingAddressCode',
            },
            {
                name        => 'shippingAddressPhoneNumber',
            },
            {
                name        => 'shippingDriverId',
            },
            {
                name        => 'shippingDriverLabel',
            },
            {
                name        => 'paymentAddressId',
            },
            {
                name        => 'paymentAddress1',
            },
            {
                name        => 'paymentAddress2',
            },
            {
                name        => 'paymentAddress3',
            },
            {
                name        => 'paymentAddressCity',
            },
            {
                name        => 'paymentAddressState',
            },
            {
                name        => 'paymentAddressCountry',
            },
            {
                name        => 'paymentAddressCode',
            },
            {
                name        => 'paymentAddressPhoneNumber',
            },
            {
                name        => 'dateOfPurchase',
            },
            {
                name        => 'isRecurring',
            },
            {
                name        => 'notes',
            },
        ],
        related     => [  
        ],
    },

};

1;  
