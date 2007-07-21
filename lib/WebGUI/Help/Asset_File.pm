package WebGUI::Help::Asset_File;

our $HELP = {

    'file template' => {
        title => 'file template title',
        body  => '',
        isa   => [
            {   namespace => "Asset_File",
                tag       => "file template asset variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
        ],
        variables => [
            { 'name' => 'fileSize' },
            { 'name' => 'fileIcon' },
            { 'name' => 'fileUrl' },
            { 'name' => 'controls' },
        ],
        fields  => [],
        related => []
    },

    'file template asset variables' => {
        private => 1,
        title   => 'file template asset var title',
        body    => '',
        isa     => [
            {   namespace => "Asset",
                tag       => "asset template asset variables"
            },
        ],
        variables => [
            { 'name' => 'cacheTimeout' },
            {   'name'        => 'filename',
                'description' => 'filename var'
            },
            { 'name' => 'storageId' },
            { 'name' => 'templateId' },
        ],
        fields  => [],
        related => []
    },

};

1;
