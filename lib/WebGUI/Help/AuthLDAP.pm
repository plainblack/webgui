package WebGUI::Help::AuthLDAP;

our $HELP = {
	'ldap authentication display account template' => {
		title => 'account-1',
		body => 'account-2',
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
				namespace => 'Wobject'
			},
		]
	},
	'ldap authentication login template' => {
		title => 'login-1',
		body => 'login-2',
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
				namespace => 'Wobject'
			},
		]
	},
	'ldap authentication anonymous registration template' => {
		title => 'create-1',
		body => 'create-2',
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
				namespace => 'Wobject'
			}
		]
	},
};

1;
