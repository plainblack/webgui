package WebGUI::Help::Auth;

our $HELP = {
	'anonymous registration template' => {
		title => 'anon reg template title',
		body => 'anon reg template body',
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
