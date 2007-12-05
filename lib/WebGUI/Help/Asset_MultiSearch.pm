package WebGUI::Help::Asset_MultiSearch;
use strict

our $HELP = {
    'multisearch template' => {
        title => 'multisearch template title',
        body  => 'multisearch template body',
        isa   => [
            {   namespace => 'Asset_MultiSearch',
                tag       => 'multi search asset template variables',
            },
            {   namespace => 'Asset_Template',
                tag       => 'template variables',
            },
            {   namespace => 'Asset',
                tag       => 'asset template',
            },
        ],
        variables => [
            {   'name'        => 'search',
                'description' => 'search.variable',
            },
            {   'name'        => 'for',
                'description' => 'for.variable',
            },
            { 'name' => 'submit', }
        ],
        fields  => [],
        related => [],
    },

    'multi search asset template variables' => {
        private => 1,
        title   => 'multi search asset template variables title',
        body    => 'multi search asset template variables body',
        isa     => [
            {   namespace => 'Asset_Wobject',
                tag       => 'wobject template variables',
            },
        ],
        fields    => [],
        variables => [ { 'name' => 'cacheTimeout', }, { 'name' => 'templateId', }, ],
        related   => [],
    },
};

1;
