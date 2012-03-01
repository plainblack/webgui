package WebGUI::i18n::English::Account;
use strict;

our $I18N = {

    'Error: Cannot instantiate template' => {
        message     => q{Error: Cannot instantiate template %s for class %s},
        lastUpdated => 1225724810,
        context     => q{Error message in Account.pm},
    },

    'account layout template' => {
        message     => q{Account Layout Template},
        context     => q{Help title},
        lastUpdated => 1230844137,
    },

    'common account variables' => {
        message     => q{Common Account Variables},
        context     => q{Help title},
        lastUpdated => 1230844137,
    },

    'profile_user_id' => {
        message     => q{The userId of the user whose account is being viewed.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'user_full_name' => {
        message     => q{The full name of the user whose account is being viewed},
        context     => q{template variable},
        lastUpdated => 1330588033,
    },

    'user_member_since' => {
        message     => q{The date this user created their account on the site, in epoch format.  Use the Date macro to change the format.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'view_profile_url' => {
        message     => q{A URL to view the user's profile.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'root_url' => {
        message     => q{The URL to go back to the Account main screen.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'back_url' => {
        message     => q{A URL to leave the Account screen and go back to the website.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'account_loop' => {
        message     => q{A loop containing information about account plugins},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'account title' => {
        message     => q{The title of this account plugin, from the config file.  Macros in the title will be expanded.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'account identifier' => {
        message     => q{The identifier for this plugin, from the config file.  Default identifiers are profile, inbox, friends, contributions, shop and user.},
        context     => q{template variable.  Note that the list of default identifiers should not be translated!},
        lastUpdated => 1230844137,
    },

    'account className' => {
        message     => q{The perl class name for this plugin.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'is_[[IDENTIFIER]]' => {
        message     => q{[[IDENTIFIER]] is replaced with the identifier from the plugin, for example, is_profile.  The resulting boolean will be true for this plugin.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'account url' => {
        message     => q{The URL to activate this plugin.},
        context     => q{template variable},
        lastUpdated => 1230845481,
    },

    'is_method_[[METHOD]]' => {
        message     => q{[[METHOD]] is replaced with the name of the default method for this plugin.  The default name for this method is view.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'is_active' => {
        message     => q{This variable will be true if this plugin is currently being viewed.},
        context     => q{template variable},
        lastUpdated => 1230844137,
    },

    'Return to Account' => {
        message     => q{Return to Account},
        context     => q{label for templates that want to provide a link back to the main account page},
        lastUpdated => 1230844137,
    },

};

1;
