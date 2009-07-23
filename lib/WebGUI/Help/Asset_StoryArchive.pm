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
                        { name => 'url' },
                        { name => 'title' },
                        { name => 'creationDate' },
                        { name => 'deleteIcon' },
                        { name => 'editIcon' },
                      ],
                    },
                ]
            },
            {   'name' => 'searchHeader' },
            {   'name' => 'searchForm'   },
            {   'name' => 'searchButton' },
            {   'name' => 'searchFooter' },
            {   'name' => 'canPostStories' },
            {   'name' => 'addStoryUrl' },
            {   'name' => 'rssUrl' },
            {   'name' => 'atomUrl' },
            {   'name' => 'keywordCloud' },
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
                    { 'name' => 'storesPerPage',
                      'description' => 'stories per page help',
                    },
                    { 'name' => 'groupToPost', },
                    { 'name' => 'templateId', },
                    { 'name' => 'storyTemplateId', },
                    { 'name' => 'photoWidth', },
                    { 'name' => 'editStoryTemplateId', },
                    { 'name' => 'keywordListTemplateId', },
                    { 'name' => 'archiveAfter', },
                    { 'name' => 'richEditorId', },
                    { 'name' => 'approvalWorkflowId', },
        ],
        related => []
    },


    'keyword list template' => {
        title => 'keyword list template',
        body  => '',
        isa   => [
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
        ],
        fields    => [],
        variables => [
            {   'name'      => 'asset_loop',
                'variables' => [
                    { 'name' => 'title',
                      description => 'asset title' },
                    { 'name' => 'url',
                      description => 'asset url' },
                ]
            },
            {   'name' => 'keyword' },
        ],
        related => []
    },

};

1;
