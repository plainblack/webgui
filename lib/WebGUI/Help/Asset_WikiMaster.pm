package WebGUI::Help::Asset_WikiMaster;
use strict;

our $HELP = {
    'wiki master search box variables' => {
        title     => 'search box variables title',
        body      => '',
        isa       => [],
        variables => [
            { 'name' => 'searchFormHeader', },
            { 'name' => 'searchQuery', },
            { 'name' => 'searchSubmit', },
            { 'name' => 'searchFormFooter', },
        ],
        fields  => [],
        related => [],
    },

    'wiki master recent changes variables' => {
        title     => 'recent changes variables title',
        body      => '',
        isa       => [],
        variables => [
            {   'name'      => 'recentChanges',
                'variables' => [
                    {   'name'        => 'title',
                        'description' => 'recent changes title',
                    },
                    {   'name'        => 'url',
                        'description' => 'recent changes url',
                    },
                    { 'name' => 'actionTaken', },
                    {   'name'        => 'username',
                        'description' => 'recent changes username',
                    },
                    {   'name'        => 'date',
                        'description' => 'recent changes date',
                    },
                    {   'name'        => 'restoreUrl',
                        'description' => 'recent changes restore url',
                    },
                    {   'name'        => 'isAvailable',
                        'description' => 'recent changes is available',
                    },
                ]
            },
            {   name        => 'canAdminister',
                description => 'canAdminister'
            },
            {   name        => 'retoreLabel',
                description => 'restoreLabel'
            },
        ],
        fields  => [],
        related => [],
    },

    'wiki master most popular variables' => {
        title     => 'most popular variables title',
        body      => '',
        isa       => [],
        variables => [
            {   'name'      => 'mostPopular',
                'variables' => [
                    {   'name'        => 'title',
                        'description' => 'most popular title',
                    },
                    {   'name'        => 'url',
                        'description' => 'most popular url',
                    },
                ]
            },
        ],
        fields  => [],
        related => [],
    },

    'front page template' => {
        title => 'front page template title',
        body  => '',
        isa   => [
            {   namespace => "Asset_WikiMaster",
                tag       => "wiki master most popular variables"
            },
            {   namespace => "Asset_WikiMaster",
                tag       => "wiki master recent changes variables"
            },
            {   namespace => "Asset_WikiMaster",
                tag       => "wiki master search box variables"
            },
            {   namespace => "Asset_WikiMaster",
                tag       => "wiki master asset variables"
            },
        ],
        variables => [
            {   'name'        => 'searchLabel',
                'description' => 'searchLabel variable',
            },
            { 'name' => 'mostPopularUrl', },
            { 'name' => 'mostPopularLabel variable', },
            { 'name' => 'recentChangesUrl', },
            { 'name' => 'recentChangesLabel variable', },
            { 'name' => 'addPageUrl', },
            { 'name' => 'addPageLabel', },
            { 'name' => 'keywords_loop', 
              'variables' => [
                { 'name' => 'title',
                  'description' => 'keyword title',
                },
                { 'name' => 'url',
                  'description' => 'keyword url',
                },
                { 'name' => 'level',
                  'description' => 'keyword level',
                },
                { 'name' => 'indent_loop',
                  'variables' => [
                      { 'name' => 'indent',
                        'description' => 'keyword indent',
                      },
                  ],
                },
              ],
            },
        ],
        fields  => [],
        related => [],
    },

    'wiki master asset variables' => {
        private => 1,
        title   => 'wiki master asset variables title',
        body    => '',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        variables => [
            { 'name' => 'groupToEditPages', },
            { 'name' => 'groupToAdminister', },
            { 'name' => 'richEditor', },
            { 'name' => 'frontPageTemplateId', },
            { 'name' => 'pageTemplateId', },
            { 'name' => 'pageHistoryTemplateId', },
            { 'name' => 'mostPopularTemplateId', },
            { 'name' => 'recentChangesTemplateId', },
            { 'name' => 'searchTemplateId', },
            {   'name'        => 'recentChangesCount',
                'description' => 'recentChangesCount hoverHelp',
            },
            {   'name'        => 'recentChangesCountFront',
                'description' => 'recentChangesCountFront hoverHelp',
            },
            {   'name'        => 'mostPopularCount',
                'description' => 'mostPopularCount hoverHelp',
            },
            {   'name'        => 'mostPopularCountFront',
                'description' => 'mostPopularCountFront hoverHelp',
            },
            { 'name' => 'approvalWorkflow', },
            { 'name' => 'thumbnailSize', },
            { 'name' => 'useContentFilter', },
            { 'name' => 'filterCode', },
            { 'name' => 'maxImageSize', },
            {
                name        => 'isSubscribed',
                description => 'help isSubscribed',
            },
            {
                name        => 'subscribeUrl',
                description => 'help subscribeUrl',
            },
            {
                name        => 'unsubscribeUrl',
                description => 'help unsubscribeUrl',
            },
        ],
        fields  => [],
        related => [],
    },

    'most popular template' => {
        title => 'most popular template title',
        body  => 'most popular template body',
        isa   => [
            {   namespace => "Asset_WikiMaster",
                tag       => "wiki master most popular variables"
            },
        ],
        variables => [
            {   'name'        => 'title',
                'description' => 'most popular title variable',
            },
            { 'name' => 'recentChangesUrl', },
            { 'name' => 'recentChangesLabel variable', },
            {   'name'        => 'searchLabel',
                'description' => 'searchLabel variable',
            },
            { 'name' => 'searchUrl', },
            {   'name'        => 'wikiHomeLabel',
                'description' => 'wikiHomeLabel variable',
            },
            { 'name' => 'wikiHomeUrl', },
        ],
        fields  => [],
        related => [],
    },

    'recent changes template' => {
        title => 'recent changes template title',
        body  => 'recent changes template body',
        isa   => [
            {   namespace => "Asset_WikiMaster",
                tag       => "wiki master recent changes variables"
            },
        ],
        variables => [
            {   'name'        => 'title',
                'description' => 'recent changes title',
            },
            {   'name'        => 'searchLabel',
                'description' => 'searchLabel variable',
            },
            { 'name' => 'searchUrl', },
            {   'name'        => 'wikiHomeLabel',
                'description' => 'wikiHomeLabel variable',
            },
            { 'name' => 'wikiHomeUrl', },
            { 'name' => 'mostPopularUrl', },
            { 'name' => 'mostPopularLabel variable', },
        ],
        fields  => [],
        related => [],
    },

    'search template' => {
        title => 'search template title',
        body  => 'search template body',
        isa   => [
            {   namespace => "Asset_WikiMaster",
                tag       => "wiki master search box variables"
            },
            {   namespace => "WebGUI",
                tag       => "pagination template variables"
            },
        ],
        variables => [
            {   'name'        => 'searchLabel',
                'description' => 'searchLabel variable',
            },
            { 'name' => 'searchUrl', },
            {   'name'        => 'wikiHomeLabel',
                'description' => 'wikiHomeLabel variable',
            },
            { 'name' => 'wikiHomeUrl', },
            { 'name' => 'mostPopularUrl', },
            { 'name' => 'mostPopularLabel variable', },
            { 'name' => 'recentChangesUrl', },
            { 'name' => 'recentChangesLabel variable', },
            { 'name' => 'resultsLabel', },
            { 'name' => 'notWhatYouWanted variable', },
            { 'name' => 'nothingFoundLabel variable', },
            { 'name' => 'addPageUrl', },
            { 'name' => 'addPageLabel', },
            { 'name' => 'performSearch', },
            {   'name'        => 'canAddPages',
                'description' => 'canAddPages variable',
            },
            {   'name'    => 'searchResults',
                variables => [ { 'name' => 'search url variable', }, { 'name' => 'search title variable', }, ],
            },
        ],
        fields  => [],
        related => [],
    },

    'by keyword template' => {
        title => 'by keyword template title',
        body  => '',
        isa   => [
            {   namespace => "WebGUI",
                tag       => "pagination template variables"
            },
        ],
        variables => [
            {   name        => 'keyword',
                description => 'by keyword keyword',
            },
            {   name        => 'pagesLoop',
                description => 'by keyword pagesLoop',
                variables   => [
                    {   name        => 'title',
                        description => 'by keyword title',
                    },
                    {   name        => 'url',
                        description => 'by keyword url',
                    },
                    {   name        => 'synopsis',
                        description => 'by keyword synopsis',
                    },
                ],
            },
        ],
        fields  => [],
        related => [],
    },


};

1;
