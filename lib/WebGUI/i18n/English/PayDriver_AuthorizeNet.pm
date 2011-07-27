package WebGUI::i18n::English::PayDriver_AuthorizeNet;

use strict;

our $I18N = {
    'cardType' => { 
        message     => q{Card Type},
        lastUpdated => 1101772177,
        context     => q{Form label in the checkout form of the AuthorizeNet module.},
    },
    'login' => { 
        message     => q{API Login},
        lastUpdated => 1247613128,
        context     => q{Form label in the configuration form of the AuthorizeNet module.},
    },
    'login help' => { 
        message     => q{The API login id for your Authorize.net account},
        lastUpdated => 1247613146,
        context     => q{Hover help for the login field of the AuthorizeNet module},
    },
    'name' => { 
        message     => q{Credit Card (Authorize.net)},
        lastUpdated => 0,
        context     => q{Name of the Authorize.net module},
    },
    'test mode' => { 
        message     => q{Test Mode},
        lastUpdated => 0,
        context     => q{Form label for test mode toggle in AuthroizeNet module},
    },
    'test mode help' => { 
        message     => q{Whether calls using this gateway should be made in test mode},
        lastUpdated => 0,
        context     => q{Hover help for test mode form field},
    },
    'transaction key' => { 
        message     => q{Transaction Key},
        lastUpdated => 1247613060,
        context     => q{Form label in the configuration form of the AuthorizeNet module.},
    },
    'transaction key help' => { 
        message     => q{The Transaction Key for your Authorize.net account},
        lastUpdated => 1247613119,
        context     => q{Hover help for the password field of the AuthorizeNet module},
    },
};

1;

#vim:ft=perl
