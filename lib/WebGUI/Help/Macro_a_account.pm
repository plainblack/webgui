package WebGUI::Help::Macro_a_account;

our $HELP = {

        'account' => {
		title => 'account title',
		body => 'account body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'account.url'
		          },
		          {
		            'name' => 'account.text'
		          }
		],
		related => [
			{
				tag => 'macros using',
				namespace => 'Macros',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

};

1;
