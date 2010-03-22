package WebGUI::Help::AuthWebGUI;
use strict;

our $HELP = {
    'webgui authentication display account template' => {
        title => 'display account template title',
        body  => '',
        isa   => [
            {   namespace => "Auth",
                tag       => "display account template"
            },
        ],
        variables => [
            { 'name' => 'account.message' },
            { 'name' => 'account.noform' },
            { 'name' => 'account.form.username' },
            { 'name' => 'account.form.username.label' },
            { 'name' => 'account.form.password' },
            { 'name' => 'account.form.password.label' },
            { 'name' => 'account.form.passwordConfirm' },
            { 'name' => 'account.form.passwordConfirm.label' },
            { 'name' => 'account.nofields' }
        ],
        fields  => [],
        related => []
    },

    'webgui authentication login template' => {
        title => 'login template title',
        body  => '',
        isa   => [
            {   namespace => "Auth",
                tag       => "login template"
            },
        ],
        variables => [
            { 'name' => 'login.message' },
            { 'name' => 'recoverPassword.isAllowed' },
            { 'name' => 'recoverPassword.url' },
            { 'name' => 'recoverPassword.label' }
        ],
        fields  => [],
        related => []
    },

    'webgui authentication anonymous registration template' => {
        title  => 'anon reg template title',
        body   => '',
        fields => [],
        isa    => [
            {   namespace => "Auth",
                tag       => "anonymous registration template"
            },
        ],
        variables => [
            { 'name' => 'create.form.hidden' },
            { 'name' => 'create.message' },
            { 'name' => 'create.form.username' },
            { 'name' => 'create.form.username.label' },
            { 'name' => 'create.form.password' },
            { 'name' => 'create.form.password.label' },
            { 'name' => 'create.form.passwordConfirm' },
            { 'name' => 'create.form.passwordConfirm.label' },
            { 'name' => 'recoverPassword.isAllowed', },
            { 'name' => 'recoverPassword.url', },
            { 'name' => 'recoverPassword.label', }
        ],
        related => []
    },

    'webgui authentication password recovery template' => {
        title     => 'recovery template title',
        body      => '',
        variables => [
            { 'name' => 'title',    },
            { 'name' => 'subtitle', },
            {   'name'        => 'recoverFormHeader',
                'description' => 'recover.form.header',
            },
            {   'name'        => 'recoverFormHidden',
                'description' => 'recover.form.hidden',
            },
            {   'name'        => 'recoverFormSubmit',
                'description' => 'recover.form.submit',
            },
            {   'name'        => 'recoverFormFooter',
                'description' => 'recover.form.footer',
            },
            {   'name'        => 'recoverFormUsername',
                'description' => 'recoverFormUsername',
            },
            {   'name'        => 'recoverFormUsernameLabel',
                'description' => 'recoverFormUsernameLabel',
            },
            {   'name'        => 'recoverMessage',
                'description' => 'recover.message',
            },
            {   'name'        => 'anonymousRegistrationIsAllowed',
                'description' => 'anonymousRegistration.isAllowed',
            },
            {   'name'        => 'createAccountUrl',
                'description' => 'createAccount.url',
            },
            {   'name'        => 'createAccountLabel',
                'description' => 'createAccount.label',
            },
            {   'name'        => 'loginUrl',
                'description' => 'login.url',
            },
            {   'name'        => 'loginLabel',
                'description' => 'login.label',
            },
            {   'name'        => 'recoverFormProfile',
                'description' => 'recoverFormProfile',
                'variables'   => [
                    {   'name'        => 'id',
                        'description' => 'recoverFormProfile id',
                    },
                    {   'name'        => 'formElement',
                        'description' => 'recoverFormProfile formElement',
                    },
                    {   'name'        => 'label',
                        'description' => 'recoverFormProfile label',
                    }
                ],
            },
        ],
        fields  => [],
        related => []
    },

    'webgui authentication password expiration template' => {
        title     => 'expired template title',
        body      => '',
        variables => [
            { 'name' => 'expired.form.header' },
            { 'name' => 'expired.form.hidden' },
            { 'name' => 'expired.form.footer' },
            { 'name' => 'expired.form.submit' },
            { 'name' => 'displayTitle' },
            { 'name' => 'expired.message' },
            { 'name' => 'create.form.oldPassword' },
            { 'name' => 'create.form.oldPassword.label' },
            { 'name' => 'expired.form.password' },
            { 'name' => 'expired.form.password.label' },
            { 'name' => 'expired.form.passwordConfirm' },
            { 'name' => 'expired.form.passwordConfirm.label' }
        ],
        fields  => [],
        related => []
    },

    'webgui deactivate account template' => {
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

    'webgui welcome message template' => {
        title => 'welcome message template title',
        body  => '',
        variables => [
            { 'name' => 'welcomeMessage' },
            { 'name' => 'newUser_username' },
            { 'name' => 'newUser_password' },
        ],
        fields  => [],
        related => []
    },

    'account activation template' => {
        title => 'account activation template title',
        body  => '',
        variables => [
            { 'name' => 'newUser_username' },
            { 'name' => 'activationUrl' },
        ],
        fields  => [],
        related => []
    },

    'webgui deactivate account template' => {
        title => 'deactivate account template title',
        body  => '',
        isa   => [
            {   namespace => "Auth",
                tag       => "deactivate account template"
            },
        ],
        variables => [
        ],
        fields  => [],
        related => []
    },

};

1;
