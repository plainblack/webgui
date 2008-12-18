package WebGUI::Help::Asset_Matrix;
use strict;

our $HELP = {

    'search template' => {
        title     => 'search template help title',
        body      => '',
        variables => [
            {   'name'      => 'compareForm', },
            {   'name'      => 'category_loop',
                'variables' => [
                    {   'name'          => 'categoryLabel'  },
                    {   'name'          => 'attribute_loop',
                        'variables'     => [
                            {   'name'          => 'label',
                                'description'   => 'tmplVar attribute_loop listing label'
                            },
                            {   'name'          => 'description',
                                'description'   => 'tmplVar attribute_loop description'
                            },
                            {   'name'          => 'form',
                                'description'   => 'tmplVar attribute_loop form' 
                            },
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
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'edit listing template',
                namespace => 'Asset_Matrix'
            },
        ],
    },

    'compare template' => {
        title     => 'comparison template help title',
        body      => '',
        variables => [
            { 'name' => 'isTooMany' },
            { 'name' => 'isTooFew' },
            {   'name'      => 'lastupdated_loop',
                'variables' => [ { 'name' => 'lastUpdated' } ]
            },
            {   'name'      => 'category_loop',
                'variables' => [
                    {   'name'        => 'category',
                        'description' => 'tmplVar category'
                    },
                ]
            }
        ],
        related => [
            {   tag       => 'search template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'main template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'listing detail template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'edit listing template',
                namespace => 'Asset_Matrix'
            },
        ],
    },

    'main template' => {
        title     => 'matrix template help title',
        body      => '',
        variables => [
            { 'name' => 'compare.form', },
            { 'name' => 'search.url' },
            { 'name' => 'isLoggedIn' },
            { 'name' => 'field.list.url' },
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
                    {   'name'        => 'url',
                        'description' => 'tmplVar best.url'
                    },
                    {   'name'        => 'category',
                        'description' => 'tmplVar best.category'
                    },
                    {   'name'        => 'name',
                        'description' => 'tmplVar best.name'
                    },
                    { 'name' => 'mean' },
                    { 'name' => 'median' },
                    { 'name' => 'count' }
                ]
            },
            {   'name'      => 'worst_rating_loop',
                'variables' => [
                    {   'name'        => 'url',
                        'description' => 'tmplVar worst.url'
                    },
                    {   'name'        => 'category',
                        'description' => 'tmplVar worst.category'
                    },
                    {   'name'        => 'name',
                        'description' => 'tmplVar worst.name'
                    },
                    {   'name'        => 'mean',
                        'description' => 'tmplVar worst.mean'
                    },
                    {   'name'        => 'median',
                        'description' => 'tmplVar worst.median'
                    },
                    {   'name'        => 'count',
                        'description' => 'tmplVar worst.count'
                    }
                ]
            },
            {   'name'      => 'last_update_loop',
                'variables' => [
                    {   'name'        => 'url',
                        'description' => 'tmplVar last.url'
                    },
                    {   'name'        => 'name',
                        'description' => 'tmplVar last.name'
                    },
                    {   'name'        => 'lastUpdated',
                        'description' => 'tmplVar last.lastUpdated'
                    }
                ]
            },
            { 'name' => 'listingCount' },
            {   'name'      => 'pending_loop',
                'variables' => [
                    {   'name'        => 'url',
                        'description' => 'tmplVar pending.url'
                    },
                    {   'name'        => 'name',
                        'description' => 'tmplVar pending.name'
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
            {   tag       => 'listing detail template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'edit listing template',
                namespace => 'Asset_Matrix'
            },
        ],
    },

    'listing detail template' => {
        title     => 'detail template help title',
        body      => '',
        variables => [
            { 'name' => 'discussion' },
            {   'name'        => 'screenshot',
                'description' => 'tmplVar screenshot'
            },
            { 'name' => 'thumbnail' },
            { 'name' => 'emailForm' },
            { 'name' => 'emailSent' },
            { 'name' => 'isPending' },
            { 'name' => 'lastUpdated_epoch' },
            { 'name' => 'lastUpdated_date' },
            { 'name' => 'id' },
            {   'name'        => 'description',
                'description' => 'listing description'
            },
            { 'name' => 'productName' },
            { 'name' => 'productUrl' },
            { 'name' => 'productUrl_click' },
            { 'name' => 'manufacturerName' },
            { 'name' => 'manufacturerUrl' },
            { 'name' => 'manufacturerUrl_click' },
            { 'name' => 'versionNumber' },
            { 'name' => 'views' },
            { 'name' => 'compares' },
            { 'name' => 'clicks' },
            { 'name' => 'ratings' },
            {   'name'      => 'CATEGORY_NAME_loop',
                'variables' => [
                    { 'name' => 'value', },
                    {   'name'        => 'name',
                        'description' => 'tmplVar name'
                    },
                    { 'name' => 'label' },
                    {   'name'        => 'description',
                        'description' => 'category listing description'
                    },
                    {   'name'        => 'category',
                        'description' => 'tmplVar category'
                    },
                    {   'name'        => 'class',
                        'description' => 'tmplVar class'
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
                namespace => 'Asset_Matrix'
            },
        ],
    },

    'edit listing template' => {
        title     => 'edit listing template help title',
        body      => '',
        variables => [
            {   'name'      => 'form',  }
        ],
        related => [
            {   tag       => 'compare template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'main template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'listing detail template',
                namespace => 'Asset_Matrix'
            },
        ],
    },
};

1;
