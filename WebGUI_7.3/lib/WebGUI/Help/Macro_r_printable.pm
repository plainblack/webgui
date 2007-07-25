package WebGUI::Help::Macro_r_printable;

our $HELP = {

        'printable' => {
		title => 'printable title',
		body => 'printable body',
		variables => [
		          {
		            'name' => 'printable.url'
		          },
		          {
		            'name' => 'printable.text'
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
