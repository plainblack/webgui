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
            { name => 'standAlone' },
            { name => 'story_loop',
              variables => [
                { name => 'url' },
                { name => 'title' },
                { name => 'creationDate' },
                { name => 'deleteIcon' },
                { name => 'editIcon' },
              ],
            },
            { name => 'topStoryDeleteIcon',
              description => 'deleteIcon', },
            { name => 'topStoryEditIcon',
              description => 'editIcon', },
            { name => 'topStoryTitle'        },
            { name => 'topStorySubtitle'     },
            { name => 'topStoryUrl'          },
            { name => 'topStoryCreationDate' },
            { name => 'topStoryImageUrl'     },
            { name => 'topStoryImageCaption' },
            { name => 'topStoryImageByline'  },
            { name => 'topStoryImageAlt'     },
            { name => 'topStoryImageTitle'   },
            { name => 'topStoryImageLink'    },
            { name => 'rssUrl'               },
            { name => 'atomUrl'              },
        ],
        related => [
              {
                  namespace => 'Asset_Story',
                  tag       => 'view template',
              }
        ],
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
