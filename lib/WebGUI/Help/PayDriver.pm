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
            },
            {
                name        => 'amount',
            },
            {
                name        => "inShopCreditDeduction",
                description    => "inShopCreditDeduction help",
                namespace   => 'Shop',
            },
            {
                name        => 'shippingPrice',
            },
            {
                name        => 'shippingAddress',
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
                    },
                    {
                        name        => 'itemShippingAddress',
                    },
                    {
                        name        => 'viewItemUrl',
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
