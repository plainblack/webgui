package WebGUI::Help::Asset_StoryTopic;
use strict;

our $HELP = {

    'view template' => {
        title => 'view template',
        body  => '',
        isa   => [
            {   namespace => "Asset_StoryTopic",
                tag       => "storytopic asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'story_loop',
              'variables' => [
                { 'name' => 'url' },
                { 'name' => 'title' },
                { 'name' => 'creationDate' },
              ],
            },
        ],
        related => []
    },

    'storytopic asset template variables' => {
        private => 1,
        title   => 'storytopic asset template variables title',
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
