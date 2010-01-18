package WebGUI::Help::Account_Shop;

use strict; 

our $HELP = { 

    'common vars' => {
        title   => 'common account variables',
        body    => '',
        private => 1,
        isa => [
            {
                tag => 'common vars',
                namespace => 'Account',
            },
        ],
        fields => [ ],
        variables => [
            { name => "manage_purchases_url", },
            { name => "managePurchasesIsActive", },
            { name => "userIsVendor", },
        ],
        related => [ ],
    },

};

1;
#vim:ft=perl
