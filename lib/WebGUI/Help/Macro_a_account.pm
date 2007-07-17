package WebGUI::Help::Macro_a_account;

our $HELP = {

        'account' => {
		title => 'account title',
		body => '',
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
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

};

1;
