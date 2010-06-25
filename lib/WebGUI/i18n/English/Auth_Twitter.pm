package WebGUI::i18n::English::Auth_Twitter;

use strict;

our $I18N = {
    'enabled' => {
        message     => q{Enabled},
        lastUpdated => 0,
        context     => q{Label for auth setting field},
    },

    'enabled help' => {
        message     => q{Enabled Twitter-based login},
        lastUpdated => 0,
        context     => q{Hover help for auth setting field},
    },

    'get key' => {
        message     => q{Get a Twitter API key from <a href="%s">%s</a>},
        lastUpdated => 0,
        context     => q{Link to get a twitter API key},
    },

    'consumer key' => {
        message     => q{Twitter Consumer Key},
        lastUpdated => 0,
        context     => q{Label for auth setting field},
    },

    'consumer key help' => {
        message     => q{The Consumer Key from your application settings},
        lastUpdated => 0,
        context     => q{Hover help for auth setting field},
    },

    'consumer secret' => {
        message     => q{Twitter Consumer Secret},
        lastUpdated => 0,
        context     => q{Label for auth setting field},
    },

    'consumer secret help' => {
        message     => q{The Consumer Secret from your application settings},
        lastUpdated => 0,
        context     => q{Hover help for auth setting field},
    },

    'choose username title' => {
        message     => q{Choose a Username},
        lastUpdated => 0,
        context     => q{Title for screen to choose a username},
    },

    'twitter screen name taken' => {
        message     => q{Your twitter screen name "%s" is taken. Please choose a new username.},
        lastUpdated => 0,
        context     => q{An error message for the choose a username screen},
    },

    'webgui username taken' => {
        message     => q{That username "%s" is taken. Please choose another.},
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
