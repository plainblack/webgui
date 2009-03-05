package WebGUI::Help::Asset_Story;
use strict;

our $HELP = {

    'edit template' => {
        title => 'edit template',
        body  => '',
        isa   => [
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
        ],
        fields    => [],
        variables => [
            { 'name'      => 'formHeader',
              'required'  => 1 },
            { 'name'      => 'formTitle', },
            { 'name'      => 'formFooter',
              'required'  => 1 },
            { 'name'      => 'titleForm', },
            { 'name'      => 'subtitleForm', },
            { 'name'      => 'bylineForm', },
            { 'name'      => 'locationForm', },
            { 'name'      => 'keywordsForm', },
            { 'name'      => 'summaryForm', },
            { 'name'      => 'highlightsForm', },
            { 'name'      => 'storyForm', },
            { 'name'      => 'saveButton', },
            { 'name'      => 'previewButton', },
            { 'name'      => 'saveAndAddButton', },
            { 'name'      => 'cancelButton', },
        ],
        related => []
    },

};

1;
