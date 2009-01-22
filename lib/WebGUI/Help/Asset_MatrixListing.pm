package WebGUI::Help::Asset_MatrixListing;
use strict;

our $HELP = {
    'listing detail template' => {
        title     => 'detail template help title',
        body      => '',
        isa    => [
            {   namespace => "Asset_Template",
                tag       => "template variables",
            },
            {   tag       => 'asset template asset variables',
                namespace => 'Asset'
            },
        ],
        variables => [
            { 'name' => 'screenshots' },
            { 'name' => 'emailForm' },
            { 'name' => 'emailSent' },
            { 'name' => 'lastUpdated_epoch' },
            { 'name' => 'lastUpdated_date' },
            { 'name' => 'description' },
            { 'name' => 'productName' },
            { 'name' => 'productUrl' },
            { 'name' => 'productUrl_click' },
            { 'name' => 'manufacturerName',
              description => 'manufacturerName description'
            },
            { 'name' => 'manufacturerUrl' },
            { 'name' => 'manufacturerUrl_click' },
            { 'name' => 'version' },
            { 'name' => 'views' },
            { 'name' => 'compares' },
            { 'name' => 'clicks' },
            { 'name' => 'ratings' },
            {   'name'      => 'CATEGORY_NAME_loop',
                'variables' => [
                    { 'name' => 'categoryLabel' },
                    {   'name'        => 'attribute_loop',
                        'variables' => [
                            { 'name' => 'label' },
                            { 'name' => 'value' },
                            { 'name' => 'fieldType' },
                        ]
                    }
                ]
            }
        ],
        related => [
            {   tag       => 'search template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'compare template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'main template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'edit listing template',
                namespace => 'Asset_MatrixListing'
            },
        ],
    },

    'edit listing template' => {
        title     => 'edit listing template help title',
        body      => '',
        isa    => [
            {   namespace => "Asset_Template",
                tag       => "template variables",
            },
            {   tag       => 'asset template asset variables',
                namespace => 'Asset'
            },
        ],
        variables => [
            {   'name'      => 'form',  }
        ],
        related => [
            {   tag       => 'search template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'compare template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'main template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'listing detail template',
                namespace => 'Asset_MatrixListing'
            },
        ],
    },
};

