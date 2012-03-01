package WebGUI::Help::Account;

use strict; 

our $HELP = { 
    'layout template' => {
        title => 'account layout template',
        body  => '',
        isa => [
            {
                tag => 'common vars',
                namespace => 'Account',
            },
            {
                tag       => "template variables",
                namespace => "Asset_Template",
            },
        ],
        fields => [ ],
        variables => [
            {
                name      => "account_loop",
                variables => [
                    {
                        name => "title",
                        description => "account title",
                    },
                    {
                        name => "identifier",
                        description => "account identifier",
                    },
                    {
                        name => "className",
                        description => "account className",
                    },
                    {
                        name => "is_[[IDENTIFIER]]",
                    },
                    {
                        name => "account url",
                    },
                    {
                        name => "is_method_[[METHOD]]",
                    },
                ],
            },
        ],
        related => [ ],
    },

    'common vars' => {
        title   => 'common account variables',
        body    => '',
        private => 1,
        isa => [ ],
        fields => [ ],
        variables => [
            { name => "profile_user_id", },
            { name => "user_full_name", },
            { name => "user_member_since", },
            { name => "view_profile_url", },
            { name => "root_url", },
            { name => "back_url", },
        ],
        related => [ ],
    },

};

1;
#vim:ft=perl
