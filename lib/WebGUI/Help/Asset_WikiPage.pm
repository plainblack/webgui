package WebGUI::Help::Asset_WikiPage;
use strict;

our $HELP = {
    'wiki page add/edit' => {
        title     => 'add/edit title',
        body      => '',
        isa       => [],
        variables => [
            { name => 'title', },
            {   name     => 'formHeader',
                required => 1,
            },
            { name => 'formTitle', },
            {   name        => 'titleLabel',
                description => 'titleLabel variable',
            },
            { name => 'formContent', },
            {   name        => 'contentLabel',
                description => 'contentLabel variable',
            },
            { name => 'formProtect', },
            {   name        => 'protectQuestionLabel',
                description => 'protectQuestionLabel variable',
            },
            {   name     => 'formSubmit',
                required => 1,
            },
            {   name     => 'formFooter',
                required => 1,
            },
            { name => 'isNew', },
            { name => 'canAdminister', },
            { name => 'isProtected', },
            {   name        => 'deleteLabel',
                description => 'deleteLabel variable',
            },
            { name => 'deleteUrl', },
            { name => 'deleteConfirmation', },
        ],
        related => [],
    },

    'view template' => {
        title => 'view title',
        body  => 'view body',
        isa   => [
            {   tag       => 'wiki page asset template variables',
                namespace => 'Asset_WikiPage'
            },
        ],
        variables => [
            {   name        => 'viewLabel',
                description => 'viewLabel variable',
            },
            {   name        => 'editLabel',
                description => 'editLabel variable',
            },
            {   name        => 'canEdit',
                description => 'canEdit variable',
            },
            {   name        => 'canAdminister', },
            {   name        => 'isProtected', },
            {   name        => 'historyLabel',
                description => 'historyLabel variable',
            },
            { name => 'historyUrl', },
            {   'name'        => 'wikiHomeLabel',
                'description' => 'wikiHomeLabel variable',
            },
            { 'name' => 'wikiHomeUrl', },
            { 'name' => 'mostPopularUrl', },
            { 'name' => 'mostPopularLabel variable', },
            { 'name' => 'recentChangesUrl', },
            { 'name' => 'recentChangesLabel', },
            {   'name'        => 'searchLabel',
                'description' => 'searchLabel variable',
            },
            { 'name' => 'editContent', },
            { 'name' => 'content', },
            { 'name' => 'keywordsLoop',
              'variables' => [
                { 'name' => 'keyword',
                  'description' => 'keyword title',
                },
                { 'name' => 'url',
                  'description' => 'keyword url',
                },
              ],
            },
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
            {
                name        => 'owner',
                description => 'help owner',
            },
        ],
        related => [],
    },

    'wiki page asset template variables' => {
        private   => 1,
        title     => 'vars title',
        body      => 'vars body',
        isa       => [],
        variables => [
            { name   => 'storageId', },
            { name   => 'content variable', },
            { name   => 'views', },
            { name   => 'isProtected', },
            { 'name' => 'actionTaken', },
            { 'name' => 'actionTakenBy', },
        ],
        related => [],
    },

    'history template' => {
        title     => 'history title',
        body      => 'history body',
        isa       => [],
        variables => [
            { 'name' => 'history toolbar', },
            { 'name' => 'history date', },
            { 'name' => 'history username', },
            { 'name' => 'history actionTaken', },
            { 'name' => 'history interval', },
        ],
        related => [],
    },


    'subscription template' => {
        title       => 'help subscription title',
        body        => 'help subscription body',
        isa         => [
            {
                tag       => 'view template',
                namespace => 'Asset_WikiPage',
            },
        ],
    },
};

1;
