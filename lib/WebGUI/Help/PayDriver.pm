package WebGUI::Help::PayDriver;

use strict; 


our $HELP = { 

    'email receipt template' => {    
        title         => 'email receipt template', 
        body         => 'email receipt template help',    
        isa         => [],
        fields         => [],
        variables     => [
            {
                name        => 'viewDetailURL',
                namespace   => 'Shop',
            },
            {
                name        => 'amount',
                description => 'amount help',
                namespace   => 'Shop',
            },
            {
                name        => 'taxes',
                description => 'taxes help',
                namespace   => 'Shop',
            },
            {
                name        => "inShopCreditDeduction",
                description => "inShopCreditDeduction help",
                namespace   => 'Shop',
            },
            {
                name        => 'shippingPrice',
                description => 'shippingPrice help',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddress',
                description => "shippingAddress help",
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddress',
                namespace   => 'Shop',
            },
            {
                name        => 'items',
                namespace   => 'Shop',
                variables   => [
                    {
                        name        => 'viewItemUrl',
                        namespace   => 'Shop',
                    },
                    {
                        name        => 'price',
                        namespace   => 'Shop',
                    },
                    {
                        name        => 'itemShippingAddress',
                        namespace   => 'Shop',
                    },
                    {
                        name        => 'orderStatus',
                        namespace   => 'Shop',
                    },
                    {
                        name        => 'itemId',
                        namespace   => 'Shop',
                    },
                    {
                        name        => 'transactionId',
                        namespace   => 'Shop',
                        description => 'item transactionId',
                    },
                    {
                        name        => 'assetId',
                        namespace   => 'Shop',
                        description => 'item assetId',
                    },
                    {
                        name        => 'configuredTitle',
                        namespace   => 'Shop',
                    },
                    {
                        name        => 'options',
                        namespace   => 'Shop',
                        description => 'item options',
                    },
                    {
                        name        => 'shippingAddressId',
                        namespace   => 'Shop',
                        description => 'item shippingAddressId',
                    },
                    {
                        name        => 'shippingName',
                        namespace   => 'Shop',
                        description => 'item shippingName',
                    },
                    {
                        name        => 'shippingAddress1',
                        namespace   => 'Shop',
                        description => 'item shippingAddress1',
                    },
                    {
                        name        => 'shippingAddress2',
                        namespace   => 'Shop',
                        description => 'item shippingAddress2',
                    },
                    {
                        name        => 'shippingAddress3',
                        namespace   => 'Shop',
                        description => 'item shippingAddress3',
                    },
                    {
                        name        => 'shippingAddressCity',
                        namespace   => 'Shop',
                        description => 'item shippingAddressCity',
                    },
                    {
                        name        => 'shippingAddressState',
                        namespace   => 'Shop',
                        description => 'item shippingAddressState',
                    },
                    {
                        name        => 'shippingAddressCountry',
                        namespace   => 'Shop',
                        description => 'item shippingAddressCountry',
                    },
                    {
                        name        => 'shippingAddressCode',
                        namespace   => 'Shop',
                        description => 'item shippingAddressCode',
                    },
                    {
                        name        => 'shippingAddressPhoneNumber',
                        namespace   => 'Shop',
                        description => 'item shippingAddressPhoneNumber',
                    },
                    {
                        name        => 'lastUpdated',
                        namespace   => 'Shop',
                        description => 'item lastUpdated',
                    },
                    {
                        name        => 'quantity',
                        namespace   => 'Shop',
                        description => 'item quantity',
                    },
                    {
                        name        => 'price',
                        namespace   => 'Shop',
                        description => 'item price',
                    },
                    {
                        name        => 'vendorId',
                        namespace   => 'Shop',
                        description => 'item vendorId',
                    },
                ],
            },
            {
                name        => 'transactionId',
                namespace   => 'Shop',
            },
            {
                name        => 'originatingTransactionId',
                namespace   => 'Shop',
            },
            {
                name        => 'isSuccessful',
                namespace   => 'Shop',
            },
            {
                name        => 'orderNumber',
                namespace   => 'Shop',
            },
            {
                name        => 'transactionCode',
                namespace   => 'Shop',
            },
            {
                name        => 'statusCode',
                namespace   => 'Shop',
            },
            {
                name        => 'statusMessage',
                namespace   => 'Shop',
            },
            {
                name        => 'userId',
                namespace   => 'Shop',
            },
            {
                name        => 'username',
                namespace   => 'Shop',
            },
            {
                name        => 'shopCreditDeduction',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddressId',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddressName',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddress1',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddress2',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddress3',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddressCity',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddressState',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddressCountry',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddressCode',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingAddressPhoneNumber',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingDriverId',
                namespace   => 'Shop',
            },
            {
                name        => 'shippingDriverLabel',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddressId',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddress1',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddress2',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddress3',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddressCity',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddressState',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddressCountry',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddressCode',
                namespace   => 'Shop',
            },
            {
                name        => 'paymentAddressPhoneNumber',
                namespace   => 'Shop',
            },
            {
                name        => 'dateOfPurchase',
                namespace   => 'Shop',
            },
            {
                name        => 'isRecurring',
                namespace   => 'Shop',
            },
            {
                name        => 'notes',
                namespace   => 'Shop',
            },
        ],
        related     => [  
        ],
    },

    'cart summary variables' => {    
        title        => 'cart summary variables', 
        body         => 'cart summary variables help',    
        isa          => [],
        fields       => [],
        private      => 1,
        variables    => [
            {
                name        => 'shippableItemsInCart',
                namespace   => 'Shop',
            },
            {
                name        => 'subtotal',
                description => 'subtotalPrice help',
                namespace   => 'Shop',
            },
            {
                name        => 'shipping',
                description => 'shippingPrice help',
                namespace   => 'Shop',
            },
            {
                name        => 'taxes',
                description => 'taxes help',
                namespace   => 'Shop',
            },
            {
                name        => 'inShopCreditAvailable',
                description => 'inShopCreditAvailable help',
                namespace   => 'Shop',
            },
            {
                name        => 'inShopCreditDeduction',
                description => 'inShopCreditDeduction help',
                namespace   => 'Shop',
            },
            {
                name        => 'totalPrice',
                description => 'totalPrice help',
                namespace   => 'Shop',
            },

};

1;  
