package WebGUI::Help::Commerce;
use strict;

our $HELP = {

    'cancel template' => {
        title     => 'help cancel checkout template title',
        body      => '',
        variables => [ { 'name' => 'message' } ],
        fields    => [],
        related   => []
    },

    'confirm template' => {
        title     => 'help checkout confirm template title',
        body      => '',
        fields    => [],
        variables => [
            { 'name' => 'title' },
            { 'name' => 'normalItems' },
            {   'name'      => 'normalItemLoop',
                'variables' => [
                    { 'name' => 'quantity' },
                    { 'name' => 'period' },
                    { 'name' => 'name' },
                    { 'name' => 'salesTax' },
                    { 'name' => 'price' },
                    { 'name' => 'totalPrice' }
                ]
            },
            { 'name' => 'recurringItems' },
            { 'name' => 'recurringItemLoop' },
            { 'name' => 'form' },
            { 'name' => 'salesTaxRate' },
            { 'name' => 'totalSalesTax' },
        ],
        related => [],
    },

    'error template' => {
        title     => 'help checkout error template title',
        body      => '',
        fields    => [],
        variables => [
            { 'name' => 'title', },
            { 'name' => 'statusExplanation' },
            {   'name'      => 'resultLoop',
                'variables' => [
                    { 'name' => 'purchaseDescription' },
                    { 'name' => 'status' },
                    { 'name' => 'error' },
                    { 'name' => 'errorCode' }
                ]
            }
        ],
        related => []
    },

    'select payment gateway template' => {
        title     => 'help select payment template title',
        body      => '',
        fields    => [],
        variables => [
            {   'name'        => 'message',
                'description' => 'gateway message'
            },
            { 'name' => 'pluginsAvailable' },
            { 'name' => 'noPluginsMessage' },
            { 'name' => 'formHeader' },
            { 'name' => 'formFooter' },
            { 'name' => 'formSubmit' },
            {   'name'      => 'pluginLoop',
                'variables' => [
                    {   'name'        => 'name',
                        'description' => 'plugin name'
                    },
                    { 'name' => 'namespace' },
                    { 'name' => 'formElement' }
                ]
            }
        ],
        related => []
    },

};

1;
