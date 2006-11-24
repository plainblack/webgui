package WebGUI::Help::Auth;

our $HELP = {
	'display account template' => {
		title => 'display account template title',
		body => 'display account template body',
		isa => [
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
		],
		variables => [
		          {
		            'name' => 'account.form.header'
		          },
		          {
		            'name' => 'account.form.submit'
		          },
		          {
		            'name' => 'account.form.footer'
		          },
		          {
		            'name' => 'account.form.karma'
		          },
		          {
		            'name' => 'account.form.karma.label'
		          },
		          {
		            'name' => 'account.options'
		          },
		],
		fields => [
		],
		related => [
		]
	},
	'anonymous registration template' => {
		title => 'anon reg template title',
		body => 'anon reg template body',
		isa => [
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'create.form.header'
		          },
		          {
		            'name' => 'create.form.footer'
		          },
		          {
		            'name' => 'create.form.submit'
		          },
		          {
		            'name' => 'title',
		          },
		          {
		            'name' => 'create.form.profile',
			    'variables' => [
				  {
				    'name' => 'profile.formElement'
				  },
				  {
				    'name' => 'profile.formElement.label'
				  },
				  {
				    'name' => 'profile.required'
				  },
			    ],
		          },
		          {
		            'name' => 'create.form.profile.id.formElement',
		          },
		          {
		            'name' => 'create.form.profile.id.formElement.label',
		          },
		          {
		            'name' => 'create.form.profile.id.required',
		          },
		          {
		            'name' => 'login.url',
		          },
		          {
		            'name' => 'login.label',
		          },
		],
		related => [
		]
	},
};

1;
