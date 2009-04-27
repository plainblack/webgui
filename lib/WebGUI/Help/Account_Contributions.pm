package WebGUI::Help::Account_Contributions;

use strict; 

our $HELP = { 
    'layout template' => {
        title => 'account contributions layout template',
        body  => '',
        isa => [
            {
                tag       => 'template variables',
                namespace => 'Asset_Template',
            },
            {
                tag       => 'pagination template variables',
                namespace => 'WebGUI',
            },
        ],
        fields => [ ],
        variables => [
                    {
                        name => 'title_url',
                    },
                    {
                        name => 'type_url',
                    },
                    {
                        name => 'dateStamp_url',
                    },
                    {
                        name => 'rpp_url',
                    },
                    {
                        name => 'has_contributions',
                    },
                    {
                        name => 'contributions_total',
                    },
                    {
                        name => 'user_full_name',
                    },
                    {
                        name => 'user_member_since',
                    },
                    {
                        name => 'view_profile_url',
                        namespace => 'Account',
                    },
                    {
                        name => 'root_url',
                        namespace => 'Account',
                    },
                    {
                        name => 'back_url',
                        namespace => 'Account',
                    },
                    {
                        name => 'contributions_loop',
                        variables => [
                            {
                                name => 'contributions_variables',
                            },
                        ],
                    },
        ],
        related => [ ],
    },

};

1;
#vim:ft=perl
