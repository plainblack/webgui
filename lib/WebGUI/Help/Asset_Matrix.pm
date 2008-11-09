package WebGUI::Help::Asset_Matrix;
use strict;

our $HELP = {

    'search template' => {
        title     => 'search template help title',
        body      => '',
        variables => [
            { 'name' => 'compare.form', },
            { 'name' => 'form.header' },
            { 'name' => 'form.footer' },
            { 'name' => 'form.submit' },
            {   'name'      => 'CATEGORY_NAME_loop',
                'variables' => [
                    {   'name'        => 'name',
                        'description' => 'listing name'
                    },
                    { 'name' => 'fieldType' },
                    {   'name'        => 'label',
                        'description' => 'listing label'
                    },
                    {   'name'        => 'description',
                        'description' => 'search field description'
                    },
                    { 'name' => 'form' }
                ],
            }
        ],
        related => [
            {   tag       => 'compare template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'ratings detail template',
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

    'compare template' => {
        title     => 'comparison template help title',
        body      => '',
        variables => [
            { 'name' => 'isTooMany' },
            { 'name' => 'isTooFew' },
            { 'name' => 'compare.form' },
            {   'name'      => 'product_loop',
                'variables' => [
                    { 'name' => 'name' },
                    { 'name' => 'version' },
                    {   'name'        => 'url',
                        'description' => 'details url'
                    }
                ]
            },
            {   'name'      => 'lastupdated_loop',
                'variables' => [ { 'name' => 'lastUpdated' } ]
            },
            {   'name'      => 'category_loop',
                'variables' => [
                    {   'name'        => 'category',
                        'description' => 'tmplVar category'
                    },
                    { 'name' => 'columnCount' },
                    {   'name'      => 'row_loop',
                        'variables' => [
                            {   'name'      => 'column_loop',
                                'variables' => [
                                    { 'name' => 'value' },
                                    { 'name' => 'class' },
                                    {   'name'        => 'description',
                                        'description' => 'tmplVar field.description'
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ],
        related => [
            {   tag       => 'search template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'ratings detail template',
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

    'ratings detail template' => {
        title     => 'ratings detail template help title',
        body      => '',
        variables => [
            {   'name'      => 'rating_loop',
                'variables' => [
                    { 'name' => 'category', },
                    {   'name'      => 'detail_loop',
                        'variables' => [
                            {   'name'        => 'url',
                                'description' => 'tmplVar detail url'
                            },
                            {   'name'        => 'mean',
                                'description' => 'detail mean'
                            },
                            {   'name'        => 'median',
                                'description' => 'detail median'
                            },
                            {   'name'        => 'count',
                                'description' => 'detail count'
                            },
                            {   'name'        => 'name',
                                'description' => 'listing name'
                            }
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
            {   tag       => 'listing detail template',
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
            { 'name' => 'ratings.details.url' },
            { 'name' => 'best.posts.url' },
            { 'name' => 'bestUpdated_url' },
            { 'name' => 'bestUpdated_date' },
            { 'name' => 'bestUpdated_name' },
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
            { 'name' => 'user.count' },
            { 'name' => 'current.user.count' },
            { 'name' => 'listingCount' },
            {   'name'      => 'pending_list',
                'variables' => [
                    {   'name'        => 'url',
                        'description' => 'tmplVar pending.url'
                    },
                    {   'name'        => 'productName',
                        'description' => 'tmplVar pending.productName'
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
            {   tag       => 'ratings detail template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'listing detail template',
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
            { 'name' => 'email.form' },
            { 'name' => 'email.wasSent' },
            { 'name' => 'edit.url' },
            { 'name' => 'user.canEdit' },
            { 'name' => 'user.canApprove' },
            { 'name' => 'approve.url' },
            { 'name' => 'delete.url' },
            { 'name' => 'isPending' },
            { 'name' => 'lastUpdated_epoch' },
            { 'name' => 'lastUpdated_date' },
            { 'name' => 'id' },
            {   'name'        => 'description',
                'description' => 'listing description'
            },
            { 'name' => 'productName' },
            { 'name' => 'productUrl' },
            { 'name' => 'productUrl.click' },
            { 'name' => 'manufacturerName' },
            { 'name' => 'manufacturerUrl' },
            { 'name' => 'manufacturerUrl.click' },
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
            {   tag       => 'ratings detail template',
                namespace => 'Asset_Matrix'
            },
            {   tag       => 'main template',
                namespace => 'Asset_Matrix'
            },
        ],
    },
};

1;
