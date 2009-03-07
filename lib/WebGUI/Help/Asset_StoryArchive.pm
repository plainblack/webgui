package WebGUI::Help::Asset_StoryArchive;
use strict;

our $HELP = {

    'view template' => {
        title => 'view template',
        body  => '',
        isa   => [
            {   namespace => "Asset_StoryArchive",
                tag       => "storyarchive asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI'
            },
        ],
        fields    => [],
        variables => [
            {   'name'      => 'date_loop',
                'variables' => [
                    { 'name' => 'epochDate' },
                    { 'name' => 'story_loop',
                      'variables' => [
                        { 'name' => 'url' },
                        { 'name' => 'title' },
                        { 'name' => 'creationDate' },
                      ],
                    },
                ]
            },
            {   'name' => 'searchHeader' },
            {   'name' => 'searchForm'   },
            {   'name' => 'searchButton' },
            {   'name' => 'searchFooter' },
        ],
        related => []
    },

    'storyarchive asset template variables' => {
        private => 1,
        title   => 'storyarchive asset template variables title',
        body    => '',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
        ],
        fields    => [],
        variables => [
        ],
        related => []
    },


};

1;
