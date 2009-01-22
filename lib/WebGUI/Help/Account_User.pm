package WebGUI::Help::Account_User;

use strict; 

our $HELP = { 
    'layout template' => {
        title => 'user layout template title',
        body  => 'user layout template body',
        isa => [
        ],
        fields => [ ],
        variables => [ ],
        related => [
            {
                tag => 'display account template',
                namespace => 'Auth',
            },
        ],
    },

};

1;
#vim:ft=perl
