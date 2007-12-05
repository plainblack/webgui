package WebGUI::Help::Macro_AdminBar;
use strict;

our $HELP = {

    'admin bar' => {
        title     => 'admin bar title',
        body      => '',
        fields    => [],
        variables => [
            {   'name'      => 'adminbar_loop',
                'variables' => [
                    { 'name' => 'label' },
                    { 'name' => 'name' },
                    {   'name'      => 'items',
                        'variables' => [ { 'name' => 'title' }, { 'name' => 'url' }, { 'name' => 'icon' } ]
                    }
                ]
            }
        ],
        related => []
    },

};

1;
