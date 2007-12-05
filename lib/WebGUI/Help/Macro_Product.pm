package WebGUI::Help::Macro_Product;
use strict

our $HELP = {

    'product' => {
        title     => 'product title',
        body      => '',
        variables => [
            { 'name' => 'variants.message' },
            {   'name'      => 'variantLoop',
                'variables' => [
                    {   'name'      => 'variant.compositionLoop',
                        'variables' => [ { 'name' => 'parameter' }, { 'name' => 'value' } ]
                    },
                    { 'name' => 'variant.variantId' },
                    { 'name' => 'variant.price' },
                    { 'name' => 'variant.weight' },
                    { 'name' => 'variant.sku' },
                    { 'name' => 'variant.addToCart.url' },
                    { 'name' => 'variant.addToCart.label' }
                ]
            },
            { 'name' => 'productId' },
            { 'name' => 'title' },
            { 'name' => 'description' },
            { 'name' => 'price' },
            { 'name' => 'weight' },
            { 'name' => 'sku' }
        ],
        fields  => [],
        related => []
    },

};

1;

