package WebGUI::Help::AuthLDAP;
use strict;

our $HELP = {
    'ldap authentication display account template' => {
        title => 'display account template title',
        body  => '',
        isa   => [
            {   namespace => "Auth",
                tag       => "display account template"
            },
        ],
        variables => [
            { 'name' => 'account.form.karma' },
            { 'name' => 'account.form.karma.label' },
            { 'name' => 'account.options' },
            { 'name' => 'displayTitle' },
            { 'name' => 'account.message' }
        ],
        fields  => [],
        related => [
            {   tag       => 'ldap authentication anonymous registration template',
                namespace => 'AuthLDAP'
            },
            {   tag       => 'ldap authentication login template',
                namespace => 'AuthLDAP'
            },
        ]
    },

    'ldap authentication login template' => {
        title => 'auth login template title',
        body  => '',
        isa   => [
            {   namespace => "Auth",
                tag       => "login template"
            },
        ],
        variables => [ { 'name' => 'login.message' }, ],
        fields    => [],
        related   => [
            {   tag       => 'ldap authentication anonymous registration template',
                namespace => 'AuthLDAP'
            },
            {   tag       => 'ldap authentication display account template',
                namespace => 'AuthLDAP'
            },
        ]
    },

    'ldap authentication anonymous registration template' => {    ##createAccount
        title => 'anon reg template title',
        body  => '',
        isa   => [
            {   namespace => "Auth",
                tag       => "anonymous registration template"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'create.message' },
            { 'name' => 'create.form.ldapConnection' },
            { 'name' => 'create.form.ldapConnection.label' },
            { 'name' => 'create.form.ldapId' },
            { 'name' => 'create.form.ldapId.label' },
            { 'name' => 'create.form.password' },
            { 'name' => 'create.form.password.label' }
        ],
        related => [
            {   tag       => 'ldap authentication display account template',
                namespace => 'AuthLDAP'
            },
            {   tag       => 'ldap authentication login template',
                namespace => 'AuthLDAP'
            },
        ]
    },

    'ldap deactivate account template' => {
        title => 'deactivate account template title',
        body  => '',
        isa   => [
            {   namespace => "Auth",
                tag       => "deactivate account template"
            },
        ],
        variables => [],
        fields    => [],
        related   => [],
    },

};

1;
