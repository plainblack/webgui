package WebGUI::i18n::English::Auth_OpenId;
use strict;

our $I18N = {

    'accept list' => {
        message     => q{Accept List (allow access from these providers):},
        lastUpdated => 1329866849,
    },
    
    'accept list help' => {
        message     => q{Enter white list providers (one per line).  Example: .google.com},
        lastUpdated => 1329866849,
    },

    'choose username template' => {
        message     => q{Choose Username Template},
        lastUpdated => 1329866849,
    },

    'choose username template help' => {
        message     => q{The template to choose a username},
        lastUpdated => 1329866849,
    },
    
    'choose username title' => {
        message     => q{Choose Username:},
        lastUpdated => 1329866849,
    },
    
    'deny list' => {
        message     => q{Deny List (no access from these providers):},
        lastUpdated => 1329866849,
    },    
    
    'deny list' => {
        message     => q{Deny List (no access from these providers):},
        lastUpdated => 1329866849,
    },
    
    'deny list help' => {
        message     => q{Enter black list providers (one per line).  Example: .google.com},
        lastUpdated => 1329866849,
    },        
    
    'disabled' => {
        message     => q{User: %s is attempting to login, however this module is dissabled.},
        lastUpdated => 1329866849,
    },       

    'enabled' => {
        message     => q{Enabled},
        lastUpdated => 1329866849,
    },
    
    'enabled help' => {
        message     => q{Enable this authentication module},
        lastUpdated => 1329866849,
    },
    
    'invalid identity' => {
        message     => q{Invalid identity: %s},
        context     => q{identity},
        lastUpdated => 1329866849,
    },
   
    'error default' => {
        message     => q{There was an error with this transaction, please try again.},
        context     => q{general},
        lastUpdated => 1329866849,
    },      
    
    'no registration hack' => {
        message     => q{attempted to complete anonymous registration, however anonymous registration is dissabled},
        lastUpdated => 1329866849,
    },
    
    'return page' => {
        message     => q{Return page:},
        context     => q{Page},
        lastUpdated => 1329866849,
    },
    
    'return user template' => {
        message     => q{Attempting to read user template:},
        context     => q{Page},
        lastUpdated => 1329866849,
    },
        
    'warnNoMatchAcceptList' => {
        message     => q{Authentication from this service provider not defined in allow list},
        context     => q{Error message in OpenId.pm},
        lastUpdated => 1329866849,
    },

    'warnFoundOnDenyList' => {
        message     => q{Authentication from this service provider prohibited by deny list},
        context     => q{Error message in OpenId.pm},
        lastUpdated => 1329866849,
    },

    'webgui username taken' => {
        message     => q{That username is already taken, your username has to be unique.  Please try another username.},
        context     => q{identity},
        lastUpdated => 1329866849,
    },
    
};

1;
