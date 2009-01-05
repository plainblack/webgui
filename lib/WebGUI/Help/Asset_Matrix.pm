package WebGUI::Help::Asset_Matrix;
use strict;

our $HELP = {

    'search template' => {
        title   => 'search template help title',
        body    => '',
	    isa     => [
            {   namespace => "Asset_Matrix",
                tag       => "matrix asset template variables",
            },
            {   namespace => "Asset_Template",
                tag       => "template variables",
            },
        ],
        variables => [
            {   'name'      => 'compareForm', },
            {   'name'      => 'category_loop',
                'variables' => [
                    {   'name'          => 'categoryLabel'  },
                    {   'name'          => 'attribute_loop',
                        'variables'     => [
                            {   'name'          => 'label' },
                            {   'name'          => 'description' },
                            {   'name'          => 'form' },
                        ],
                    },
                ],
            }
        ],
        related => [
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

    'compare template' => {
        title   => 'comparison template help title',
        body    => 'comparison template help body',
        isa     => [
            {   namespace => "Asset_Matrix",
                tag       => "matrix asset template variables",
            },
            {   namespace => "Asset_Template",
                tag       => "template variables",
            },
        ],
        variables => [
            { 'name' => 'javascript' },
        ],
        related => [
            {   tag       => 'search template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'main template',
                namespace => 'Asset_Matrix'
            },
        ],
    },

    'main template' => {
        title   => 'matrix template help title',
        body    => '',
        isa     => [
            {   namespace => "Asset_Matrix",
                tag       => "matrix asset template variables",
            },
            {   namespace => "Asset_Template",
                tag       => "template variables",
            },
        ],
        variables => [
            { 'name' => 'compareForm', },
            { 'name' => 'isLoggedIn' },
            { 'name' => 'listAttributes_url' },
            { 'name' => 'addMatrixListing_url' },
            { 'name' => 'bestViews_url' },
            { 'name' => 'bestViews_count' },
            { 'name' => 'bestViews_name' },
            { 'name' => 'bestCompares_url' },
            { 'name' => 'bestCompares_count' },
            { 'name' => 'bestCompares_name' },
            { 'name' => 'bestClicks_url' },
            { 'name' => 'bestClicks_count' },
            { 'name' => 'bestClicks_name' },
            {   'name'      => 'best_rating_loop',
                'variables' => [
                    { 'name' => 'url' },
                    { 'name' => 'category' },
                    { 'name' => 'name' },
                    { 'name' => 'mean' },
                    { 'name' => 'median' },
                    { 'name' => 'count' }
                ]
            },
            {   'name'      => 'worst_rating_loop',
                'variables' => [
                    { 'name' => 'url' },
                    { 'name' => 'category' },
                    { 'name' => 'name' },
                    { 'name' => 'mean' },
                    { 'name' => 'median' },
                    { 'name' => 'count' }
                ]
            },
            {   'name'      => 'last_updated_loop',
                'variables' => [
                    {   'name'        => 'url' },
                    {   'name'        => 'name' },
                    {   'name'        => 'lastUpdated' },
                ]
            },
            { 'name' => 'listingCount' },
            {   'name'      => 'pending_loop',
                'variables' => [
                    {   'name'        => 'url' },
                    {   'name'        => 'name' },
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
        ],
    },

    'matrix asset template variables' => {
        private => 1,
        title   => 'matrix asset template variables title',
        body    => '',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables",
            },
        ],
        fields    => [],
        variables => [],
        related => [
            {   tag       => 'listing detail template',
                namespace => 'Asset_MatrixListing'
            },
            {   tag       => 'edit listing template',
                namespace => 'Asset_MatrixListing'
            },
        ],
    },
};

1;
