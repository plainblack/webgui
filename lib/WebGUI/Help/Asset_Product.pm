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
            { 'name' => 'brochure.icon' },
            { 'name' => 'brochure.url' },
            { 'name' => 'brochure.label' },
            { 'name' => 'manual.icon' },
            { 'name' => 'manual.url' },
            { 'name' => 'manual.label' },
            { 'name' => 'warranty.icon' },
            { 'name' => 'warranty.url' },
            { 'name' => 'warranty.label' },
            { 'name' => 'image1' },
            { 'name' => 'thumbnail1' },
            { 'name' => 'image2' },
            { 'name' => 'thumbnail2' },
            { 'name' => 'image3' },
            { 'name' => 'thumbnail3' },
            { 'name' => 'addfeature.url' },
            { 'name' => 'addfeature.label' },
            {   'name'      => 'feature_loop',
                'variables' => [ { 'name' => 'feature.controls' }, { 'name' => 'feature.feature' } ]
            },
            { 'name' => 'addbenefit.url' },
            { 'name' => 'addbenefit.label' },
            {   'name'      => 'benefit_loop',
                'variables' => [ { 'name' => 'benefit.benefit' }, { 'name' => 'benefit.controls' } ]
            },
            { 'name' => 'addspecification.url' },
            { 'name' => 'addspecification.label' },
            {   'name'      => 'specification_loop',
                'variables' => [
                    { 'name' => 'specification.controls' },
                    { 'name' => 'specification.specification' },
                    { 'name' => 'specification.units' },
                    { 'name' => 'specification.label' }
                ]
            },
            { 'name' => 'addaccessory.url' },
            { 'name' => 'addaccessory.label' },
            {   'name'      => 'accessory_loop',
                'variables' => [
                    { 'name' => 'accessory.url' },
                    { 'name' => 'accessory.title' },
                    { 'name' => 'accessory.controls' }
                ]
            },
            { 'name' => 'addRelatedProduct.url' },
            { 'name' => 'addRelatedProduct.label' },
            {   'name'      => 'relatedproduct.loop',
                'variables' => [
                    { 'name' => 'relatedproduct.url' },
                    { 'name' => 'relatedproduct.title' },
                    { 'name' => 'relatedproduct.controls' }
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
                tag       => 'wobject template variables'
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
