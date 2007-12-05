package WebGUI::Help::Asset_HttpProxy;
use strict

our $HELP = {
    'http proxy template' => {
        title => 'http proxy template title',
        body  => 'http proxy template body',
        isa   => [
            {   namespace => 'Asset_HttpProxy',
                tag       => 'http proxy asset template variables',
            },
            {   namespace => 'Asset_Template',
                tag       => 'template variables',
            },
            {   namespace => 'Asset',
                tag       => 'asset template',
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'header', },
            { 'name' => 'content', },
            { 'name' => 'search.for', },
            { 'name' => 'stop.at', },
            { 'name' => 'content.leading', },
            { 'name' => 'content.trailing', },
        ],
        related => [],
    },

    'http proxy asset template variables' => {
        private => 1,
        title   => 'http proxy asset template variables title',
        body    => 'http proxy asset template variables body',
        isa     => [
            {   namespace => 'Asset_Wobject',
                tag       => 'wobject template variables',
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'templateId', },
            { 'name' => 'proxiedUrl', },
            { 'name' => 'useAmpersand', },
            { 'name' => 'timeout', },
            { 'name' => 'removeStyle', },
            { 'name' => 'cacheTimeout', },
            { 'name' => 'filterHtml', },
            { 'name' => 'followExternal', },
            { 'name' => 'rewriteUrls', },
            { 'name' => 'followRedirect', },
            { 'name' => 'searchFor', },
            { 'name' => 'stopAt', },
            { 'name' => 'cookieJarStorageId', },
        ],
        related => [],
    },

};

1;
