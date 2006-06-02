package WebGUI::Help::Macro_GroupDelete;

our $HELP = {

        'group delete' => {
		title => 'group delete title',
		body => 'group delete body',
		variables => [
		          {
		            'name' => 'group.url'
		          },
		          {
		            'name' => 'group.text'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
		]
	},

};

1;
