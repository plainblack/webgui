package WebGUI::Help::AuthLDAP;

our $HELP = {
	'ldap connection add/edit' => {
		title => 'LDAPLink_990',
		body => 'ldap connection add/edit body',
		fields => [
                        {
                                title => 'LDAPLink_992',
                                description => 'LDAPLink_992 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => 'LDAPLink_993',
                                description => 'LDAPLink_993 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => 'LDAPLink_994',
                                description => 'LDAPLink_994 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => 'LDAPLink_995',
                                description => 'LDAPLink_995 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => '9',
                                description => '9 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => '6',
                                description => '6 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => '7',
                                description => '7 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => '8',
                                description => '8 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => '868',
                                description => '868 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => '869',
                                description => '869 description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => 'account template',
                                description => 'account template description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => 'create account template',
                                description => 'create account template description',
                                namespace => 'AuthLDAP',
                        },
                        {
                                title => 'login template',
                                description => 'login template description',
                                namespace => 'AuthLDAP',
                        },
		],
		related => [ ],
	},

	'ldap authentication display account template' => {
		title => 'display account template title',
		body => 'display account template body',
		variables => [
		          {
		            'name' => 'account.form.karma'
		          },
		          {
		            'name' => 'account.form.karma.label'
		          },
		          {
		            'name' => 'account.options'
		          },
		          {
		            'name' => 'displayTitle'
		          },
		          {
		            'name' => 'account.message'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'ldap authentication anonymous registration template',
				namespace => 'AuthLDAP'
			},
			{
				tag => 'ldap authentication login template',
				namespace => 'AuthLDAP'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			},
		]
	},

	'ldap authentication login template' => {
		title => 'auth login template title',
		body => 'auth login template body',
		variables => [
		          {
		            'name' => 'login.form.header'
		          },
		          {
		            'name' => 'login.form.hidden'
		          },
		          {
		            'name' => 'login.form.footer'
		          },
		          {
		            'name' => 'login.form.submit'
		          },
		          {
		            'name' => 'login.form.username'
		          },
		          {
		            'name' => 'login.form.username.label'
		          },
		          {
		            'name' => 'login.form.password'
		          },
		          {
		            'name' => 'login.form.password.label'
		          },
		          {
		            'name' => 'title',
		          },
		          {
		            'name' => 'login.message'
		          },
		          {
		            'name' => 'anonymousRegistration.isAllowed'
		          },
		          {
		            'name' => 'createAccount.url'
		          },
		          {
		            'name' => 'createAccount.label'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'ldap authentication anonymous registration template',
				namespace => 'AuthLDAP'
			},
			{
				tag => 'ldap authentication display account template',
				namespace => 'AuthLDAP'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			},
		]
	},

	'ldap authentication anonymous registration template' => {
		title => 'anon reg template title',
		body => 'anon reg template body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'create.form.header'
		          },
		          {
		            'name' => 'create.form.hidden'
		          },
		          {
		            'name' => 'create.form.footer'
		          },
		          {
		            'name' => 'create.form.submit'
		          },
		          {
		            'name' => 'title'
		          },
		          {
		            'name' => 'create.form.profile',
		            'variables' => [
		                             {
		                               'name' => 'profile.formElement'
		                             },
		                             {
		                               'name' => 'profile.formElement.label'
		                             }
		                           ]
		          },
		          {
		            'name' => 'login.url'
		          },
		          {
		            'name' => 'login.label'
		          },
		          {
		            'name' => 'create.message'
		          },
		          {
		            'name' => 'create.form.ldapId'
		          },
		          {
		            'name' => 'create.form.ldapId.label'
		          },
		          {
		            'name' => 'create.form.password'
		          },
		          {
		            'name' => 'create.form.password.label'
		          }
		],
		related => [
			{
				tag => 'ldap authentication display account template',
				namespace => 'AuthLDAP'
			},
			{
				tag => 'ldap authentication login template',
				namespace => 'AuthLDAP'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
};

1;
