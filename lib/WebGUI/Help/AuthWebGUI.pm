package WebGUI::Help::AuthWebGUI;

our $HELP = {
	'webgui authentication display account template' => {
		title => 'display account template title',
		body => 'display account template body',
		isa => [
			{
				namespace => "Auth",
				tag => "display account template"
			},
		],
		variables => [
		          {
		            'name' => 'account.message'
		          },
		          {
		            'name' => 'account.form.username'
		          },
		          {
		            'name' => 'account.form.username.label'
		          },
		          {
		            'name' => 'account.form.password'
		          },
		          {
		            'name' => 'account.form.password.label'
		          },
		          {
		            'name' => 'account.form.passwordConfirm'
		          },
		          {
		            'name' => 'account.form.passwordConfirm.label'
		          },
		          {
		            'name' => 'account.noform'
		          },
		          {
		            'name' => 'account.nofields'
		          }
		],
		fields => [
		],
		related => [
		]
	},
	'webgui authentication login template' => {
		title => 'login template title',
		body => 'login template body',
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
		            'name' => 'title'
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
		          },
		          {
		            'name' => 'recoverPassword.isAllowed'
		          },
		          {
		            'name' => 'recoverPassword.url'
		          },
		          {
		            'name' => 'recoverPassword.label'
		          }
		],
		fields => [
		],
		related => [
		]
	},
	'webgui authentication anonymous registration template' => {
		title => 'anon reg template title',
		body => 'anon reg template body',
		fields => [
		],
		isa => [
			{
				namespace => "Auth",
				tag => "anonymous registration template"
			},
		],
		variables => [
		          {
		            'name' => 'create.form.hidden'
		          },
		          {
		            'name' => 'create.message'
		          },
		          {
		            'name' => 'create.form.username'
		          },
		          {
		            'name' => 'create.form.username.label'
		          },
		          {
		            'name' => 'create.form.password'
		          },
		          {
		            'name' => 'create.form.password.label'
		          },
		          {
		            'name' => 'create.form.passwordConfirm'
		          },
		          {
		            'name' => 'create.form.passwordConfirm.label'
		          },
		          {
		            'name' => 'recoverPassword.isAllowed',
		          },
		          {
		            'name' => 'recoverPassword.url',
		          },
		          {
		            'name' => 'recoverPassword.label',
		          }
		],
		related => [
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'webgui authentication password recovery template' => {
		title => 'recovery template title',
		body => 'recovery template body',
		variables => [
		          {
		            'name' => 'recover.form.header'
		          },
		          {
		            'name' => 'recover.form.hidden'
		          },
		          {
		            'name' => 'recover.form.footer'
		          },
		          {
		            'name' => 'recover.form.submit'
		          },
		          {
		            'name' => 'login.form.email'
		          },
		          {
		            'name' => 'login.form.email.label'
		          },
		          {
		            'name' => 'title',
		          },
		          {
		            'name' => 'recover.message'
		          },
		          {
		            'name' => 'anonymousRegistration.isAllowed',
		          },
		          {
		            'name' => 'createAccount.url',
		          },
		          {
		            'name' => 'createAccount.label',
		          },
		          {
		            'name' => 'login.url'
		          },
		          {
		            'name' => 'login.label'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'webgui authentication password expiration template' => {
		title => 'expired template title',
		body => 'expired template body',
		variables => [
		          {
		            'name' => 'expired.form.header'
		          },
		          {
		            'name' => 'expired.form.hidden'
		          },
		          {
		            'name' => 'expired.form.footer'
		          },
		          {
		            'name' => 'expired.form.submit'
		          },
		          {
		            'name' => 'displayTitle'
		          },
		          {
		            'name' => 'expired.message'
		          },
		          {
		            'name' => 'create.form.oldPassword'
		          },
		          {
		            'name' => 'create.form.oldPassword.label'
		          },
		          {
		            'name' => 'expired.form.password'
		          },
		          {
		            'name' => 'expired.form.password.label'
		          },
		          {
		            'name' => 'expired.form.passwordConfirm'
		          },
		          {
		            'name' => 'expired.form.passwordConfirm.label'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
};

1;
