package WebGUI::Help::Asset_WSClient;
use strict

our $HELP = {
    'ws client template' => {
        title => '72',
        body  => '',
        isa   => [
            {   tag       => 'ws client asset template variables',
                namespace => 'Asset_WSClient'
            },
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI'
            },
        ],
        variables => [
            { 'name' => 'disableWobject' },
            { 'name' => 'numResults' },
            { 'name' => 'soapError' },
            { 'name' => 'results', },
        ],
        fields  => [],
        related => [
            {   tag       => 'wobject template',
                namespace => 'Asset_Wobject'
            }
        ]
    },

    'ws client asset template variables' => {
        private => 1,
        title   => 'ws client asset template variables title',
        body    => '',
        isa     => [
            {   tag       => "wobject template variables",
                namespace => 'Asset_Wobject'
            },
        ],
        variables => [
            { 'name' => 'templateId' },
            { 'name' => 'callMethod' },
            { 'name' => 'debugMode' },
            { 'name' => 'execute_by_default' },
            { 'name' => 'paginateAfter' },
            { 'name' => 'paginateVar' },
            { 'name' => 'params' },
            { 'name' => 'preprocessMacros' },
            { 'name' => 'proxy' },
            { 'name' => 'uri' },
            { 'name' => 'decodeUtf8' },
            { 'name' => 'httpHeader' },
            { 'name' => 'cacheTTL' },
            { 'name' => 'sharedCache' },
        ],
        fields  => [],
        related => []
    },

};

1;
