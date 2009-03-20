package WebGUI::Help::Asset_Story;
use strict;

our $HELP = {

    'edit template' => {
        title => 'edit template',
        body  => '',
        isa   => [
            {   namespace => 'Asset_Template',
                tag       => 'template variables'
            },
        ],
        fields    => [],
        variables => [
            { name      => 'formHeader',
              'required'  => 1 },
            { name      => 'formTitle', },
            { name      => 'formFooter',
              'required'  => 1 },
            { name      => 'titleForm', },
            { name      => 'subtitleForm', },
            { name      => 'bylineForm', },
            { name      => 'locationForm', },
            { name      => 'keywordsForm', },
            { name      => 'summaryForm', },
            { name      => 'highlightsForm', },
            { name      => 'storyForm', },
            { name      => 'saveButton', },
            { name      => 'previewButton', },
            { name      => 'saveAndAddButton', },
            { name      => 'cancelButton', },
        ],
        related => []
    },

    'view template' => {
        title => 'view template',
        body  => '',
        isa   => [
            {   namespace => 'Asset_Template',
                tag       => 'template variables'
            },
        ],
        fields    => [],
        variables => [
            { name      => 'highlights_loop',
              'variables' => [
                { name      => 'highlight', },
              ],
            },
            { name      => 'keywords_loop',
              'variables' => [
                { name      => 'keyword', },
                { name      => 'url',
                  description => 'keyword_url'
                },
              ],
            },
            { name      => 'updatedTime', },
            { name      => 'updatedTimeEpoch', },
            { name      => 'crumb_loop',
              'variables' => [
                { name      => 'title',
                  description => 'crumb_title'
                },
                { name      => 'url',
                  description => 'crumb_url'
                },
              ],
            },
        ],
        related => []
    },

    'story asset template variables' => {
        private => 1,
        title   => 'story asset template variables title',
        body    => '',
        isa     => [
            {   namespace => 'Asset',
                tag       => 'asset template variables'
            },
        ],
        fields    => [],
        variables => [
            { name => 'headline',
              description => 'headline tmplvar',
            },
            { name => 'subtitle',
              description => 'subtitle tmplvar',
            },
            { name => 'byline',
              description => 'byline tmplvar',
            },
            { name      => 'updatedTime', },
            { name      => 'updatedTimeEpoch', },
        ],
        related => []
    },

    'story asset template variables' => {
        private => 1,
        title   => 'story asset template variables title',
        body    => '',
        isa     => [
            {   namespace => 'Asset',
                tag       => 'asset template variables'
            },
        ],
        fields    => [],
        variables => [
            { name => 'headline',
              description => 'headline tmplvar',
            },
            { name => 'subtitle',
              description => 'subtitle tmplvar',
            },
            { name => 'byline',
              description => 'byline tmplvar',
            },
            { name => 'location',
              description => 'location tmplvar',
            },
            { name => 'highlights',
              description => 'highlights tmplvar',
            },
            { name => 'story',
              description => 'story tmplvar',
            },
            { name => 'photo',
              description => 'photo tmplvar',
            },
            { name => 'storageId',
              description => 'storageId tmplvar',
            },
        ],
        related => []
    },

};

1;
