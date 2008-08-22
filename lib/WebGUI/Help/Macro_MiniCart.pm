package WebGUI::Help::Macro_MiniCart;

use strict; 

our $HELP = { 
    'template variables' => {
        title => 'minicart title',
        body => '',
        fields => [],
        variables => [
            {
                name      => 'items',
                variables => [
                    {
                        name => 'name',
                    },
                    {
                        name => 'quantity',
                    },
                    {
                        name => 'price',
                    },
                    {
                        name => 'url',
                    },
                ],
            },
            {
                name => 'totalPrice',
            },
            {
                name => 'totalItems',
            },
        ],
        related => [
        ],
    },

};

1;  ##All perl modules must return true
