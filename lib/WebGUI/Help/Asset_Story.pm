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
              required  => 1 },
            { name      => 'formTitle', },
            { name      => 'formFooter',
              required  => 1 },
            { name      => 'titleForm', },
            { name      => 'headlineForm', },
            { name      => 'subtitleForm', },
            { name      => 'bylineForm', },
            { name      => 'locationForm', },
            { name      => 'keywordsForm', },
            { name      => 'summaryForm', },
            { name      => 'highlightsForm', },
            { name      => 'storyForm', },
            { name      => 'saveButton', },
            { name      => 'saveAndAddButton', },
            { name      => 'cancelButton', },
            { name      => 'photo_form_loop',
              variables => [
                { name      => 'hasPhoto',       },
                { name      => 'imgThumb',       },
                { name      => 'imgUrl',         },
                { name      => 'imgFilename',    },
                { name      => 'newUploadForm',  },
                { name      => 'imgRemoteUrlForm',  },
                { name      => 'imgCaptionForm', },
                { name      => 'imgBylineForm',  },
                { name      => 'imgAltForm',     },
                { name      => 'imgTitleForm',   },
                { name      => 'imgUrlForm',     },
                { name      => 'imgDeleteForm',  },
              ],
            },
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
            { name      => 'canEdit', },
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
            { name      => 'photoWidth',   },
            { name      => 'photoHeight',   },
            { name      => 'hasPhotos',   },
            { name      => 'singlePhoto', },
            { name      => 'photo_loop',
              'variables' => [
                { name      => 'imageUrl', },
                { name      => 'imageCaption', },
                { name      => 'imageByline', },
                { name      => 'imageAlt', },
                { name      => 'imageTitle', },
                { name      => 'imageLink', },
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
                tag       => 'asset template asset variables'
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
        ],
        related => []
    },

};

1;
