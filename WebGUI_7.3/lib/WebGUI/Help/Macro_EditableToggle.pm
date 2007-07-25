package WebGUI::Help::Macro_EditableToggle;

our $HELP = {

        'editable toggle' => {
		title => 'editable toggle title',
		body => 'editable toggle body',
		variables => [
		          {
		            'name' => 'toggle.url'
		          },
		          {
		            'name' => 'toggle.text'
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
