package WebGUI::Help::Asset_Carousel;
use strict;

our $HELP = {

    'search template' => {
        title   => 'carousel template help title',
        body    => '',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables",
            },
        ],
        variables => [
            {   'name'      => 'item_loop',
                'variables' => [
                    {   'name'          => 'text'  },
                    {   'name'          => 'itemId'},
                    {   'name'          => 'sequenceNumber'},
                ],
            },
            {   'name'      => 'slideWidth', },
        ],
        related => [],
    },

};

1;

