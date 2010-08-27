package WebGUI::i18n::English::Auth_Facebook;

use strict;

our $I18N = {
    'enabled' => {
        message     => q{Enabled},
        lastUpdated => 0,
        context     => q{Label for auth setting field},
    },

    'enabled help' => {
        message     => q{Enabled Facebook-based login},
        lastUpdated => 0,
        context     => q{Hover help for auth setting field},
    },

    'get app id' => {
        message     => q{Get a Facebook App Id from <a href="http://apps.facebook.com/developer">http://apps.facebook.com/developer</a>},
        lastUpdated => 0,
        context     => q{Link to get a Facebook App Id},
    },

    'app id' => {
        message     => q{Application Id},
        lastUpdated => 0,
        context     => q{Label for auth setting field},
    },

    'app id help' => {
        message     => q{The Application ID from your Facebook application settings},
        lastUpdated => 0,
        context     => q{Hover help for auth setting field},
    },

    'secret' => {
        message     => q{Application Secret},
        lastUpdated => 0,
        context     => q{Label for auth setting field},
    },

    'secret help' => {
        message     => q{The Facebook Application Secret from your application settings},
        lastUpdated => 0,
        context     => q{Hover help for auth setting field},
    },

    'choose username title' => {
        message     => q{Choose a Username},
        lastUpdated => 0,
        context     => q{Title for screen to choose a username},
    },

    'username taken' => {
        message     => q{That username "%s" is taken. Please choose a new username.},
        lastUpdated => 0,
        context     => q{An error message for the choose a username screen},
    },

    'choose username template' => {
        message     => q{Choose Username Template},
        lastUpdated => 0,
        context     => q{Label for auth setting field},
    },

    'choose username template help' => {
        message     => q{The template to choose a username if the user's screen name already exists},
        lastUpdated => 0,
        context     => q{Hover help for auth setting field},
    },
};

1;
#vim:ft=perl
