package WebGUI::Help::Asset_Shortcut;

our $HELP = {

    'shortcut template' => {
        title => 'shortcut template title',
        body  => '',
        isa   => [
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        variables => [
            { 'name' => 'shortcut.content' },
            { 'name' => 'originalURL' },
            { 'name' => 'isShortcut' },
            { 'name' => 'shortcut.label' },
            { 'name' => 'shortcut.properties' }
        ],
        fields  => [],
        related => []
    },

};

1;
