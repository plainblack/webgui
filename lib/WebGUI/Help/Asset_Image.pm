package WebGUI::Help::Asset_Image;
use strict;

our $HELP = {

    'image template' => {
        title => 'image template title',
        body  => '',
        isa   => [
            {   namespace => "Asset_Image",
                tag       => "image template asset variables"
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
            { 'name' => 'fileIcon' },
            { 'name' => 'fileUrl' },
            { 'name' => 'controls' },
            {   'name'        => 'thumbnail',
                'description' => 'thumbnail variable'
            },
        ],
        related => []
    },

    'image template asset variables' => {
        private => 1,
        title   => 'image template asset var title',
        body    => '',
        isa     => [
            {   namespace => "Asset_File",
                tag       => "file template asset variables"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'thumbnailSize' },
            {   'name'        => 'parameters',
                'description' => 'parameters variable'
            },
        ],
        related => []
    },

};

1;
