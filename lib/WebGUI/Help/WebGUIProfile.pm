package WebGUI::Help::WebGUIProfile;

use strict; 


our $HELP = { 

    'view profile template' => {
        title => 'view profile template title',
        body => 'view profile template body',
        fields => [],
        variables => [
            {
                name        => 'displayTitle',
            },
            {
                name        => 'profile.elements',
                required    => 1,
                variables   => [
                    {
                        name        => 'profile.category',
                    },
                    {
                        name        => 'profile.label',
                    },
                    {
                        name        => 'profile.value',
                    },
                    
                ],
            },
            {
                name        => 'profile.accountOptions',
                required    => 1,
                variables   => [
                    {
                        name        => 'account.options',
                        required    => 1,
                    },
                ],
            },
        ],
        related => [
        ],
    },

    'edit profile template' => {
        title => 'edit profile template title',
        body => 'edit profile template body',
        fields => [],
        variables => [
            {
                name        => 'displayTitle',
            },
            {
                name        => 'profile.message',
                required    => 1,
            },
            {
                name        => 'profile.form.header',
                required    => 1,
            },
            {
                name        => 'profile.form.footer',
                required    => 1,
            },
            {
                name        => 'profile.form.hidden',
                required    => 1,
            },
            {
                name        => 'profile.elements',
                required    => 1,
                variables   => [
                    {
                        name        => 'profile.category',
                    },
                    {
                        name        => 'profile.label',
                    },
                    {
                        name        => 'profile.value',
                    },
                    
                ],
            },
            {
                name        => 'profile.accountOptions',
                required    => 1,
                variables   => [
                    {
                        name        => 'account.options',
                        required    => 1,
                    },
                ],
            },
        ],
        related => [
        ],
    },

};

1;  ##All perl modules must return true
