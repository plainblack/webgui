package WebGUI::Help::Asset_Product;
use strict;

our $HELP = {
    'product template' => {
        title => '62',
        body  => '',
        isa   => [
            {   namespace => 'Asset_Product',
                tag       => 'product asset template variables'
            },
            {   namespace => 'Asset_Template',
                tag       => 'template variables'
            },
            {   namespace => 'Asset',
                tag       => 'asset template'
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'canEdit' },
            { 'name' => 'brochure_icon' },
            { 'name' => 'brochure_url' },
            { 'name' => 'brochure_label' },
            { 'name' => 'manual_icon' },
            { 'name' => 'manual_url' },
            { 'name' => 'manual_label' },
            { 'name' => 'warranty_icon' },
            { 'name' => 'warranty_url' },
            { 'name' => 'warranty_label' },
            { 'name' => 'image1' },
            { 'name' => 'thumbnail1' },
            { 'name' => 'image2' },
            { 'name' => 'thumbnail2' },
            { 'name' => 'image3' },
            { 'name' => 'thumbnail3' },
            { 'name' => 'addfeature_url' },
            { 'name' => 'addfeature_label' },
            {   'name'      => 'feature_loop',
                'variables' => [ { 'name' => 'feature_controls' }, { 'name' => 'feature_feature' } ]
            },
            { 'name' => 'addbenefit_url' },
            { 'name' => 'addbenefit_label' },
            {   'name'      => 'benefit_loop',
                'variables' => [ { 'name' => 'benefit_benefit' }, { 'name' => 'benefit_controls' } ]
            },
            { 'name' => 'addvariant_url' },
            { 'name' => 'addvariant_label' },
            {   'name'      => 'variant_loop',
                'variables' => [
                    { 'name' => 'variant_id' },
                    { 'name' => 'variant_controls' },
                    { 'name' => 'variant_sku' },
                    { 'name' => 'variant_title' },
                    { 'name' => 'variant_price' },
                    { 'name' => 'variant_weight' },
                    { 'name' => 'variant_quantity' },
                ]
            },
            { 'name' => 'in_stock' },
            { 'name' => 'no_stock_message' },
            { 'name' => 'buy_form_header' },
            { 'name' => 'buy_options',
               description => 'buy_form_options' },
            { 'name' => 'buy_button',
              description => 'buy_form_button' },
            { 'name' => 'buy_form_footer' },
			{ 'name' => "hasAddedToCart" , required=>1 },
			{ 'name' => "thankYouMessage", description=>"thank you message help" },
			{ 'name' => "continueShoppingUrl" },
            { 'name' => 'addspecification_url' },
            { 'name' => 'addspecification_label' },
            {   'name'      => 'specification_loop',
                'variables' => [
                    { 'name' => 'specification_controls' },
                    { 'name' => 'specification_specification' },
                    { 'name' => 'specification_units' },
                    { 'name' => 'specification_label' }
                ]
            },
            { 'name' => 'addaccessory_url' },
            { 'name' => 'addaccessory_label' },
            {   'name'      => 'accessory_loop',
                'variables' => [
                    { 'name' => 'accessory_url' },
                    { 'name' => 'accessory_title' },
                    { 'name' => 'accessory_controls' }
                ]
            },
            { 'name' => 'addRelatedProduct_url' },
            { 'name' => 'addRelatedProduct_label' },
            {   'name'      => 'relatedproduct_loop',
                'variables' => [
                    { 'name' => 'relatedproduct_url' },
                    { 'name' => 'relatedproduct_title' },
                    { 'name' => 'relatedproduct_controls' }
                ]
            }
        ],
        related => []
    },

    'product asset template variables' => {
        private => 1,
        title   => 'product asset template variables title',
        body    => 'product asset template variables body',
        isa     => [
            {   namespace => 'Asset_Sku',
                tag       => 'sku properties'
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'cacheTimeout' },
            { 'name' => 'templateId' },
            { 'name' => 'price' },
            { 'name' => 'image1' },
            { 'name' => 'image2' },
            { 'name' => 'image3' },
            { 'name' => 'brochure' },
            { 'name' => 'manual' },
            { 'name' => 'warranty' },
        ],
        related => []
    },
};

1;
