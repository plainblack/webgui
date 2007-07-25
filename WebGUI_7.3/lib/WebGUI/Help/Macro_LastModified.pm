package WebGUI::Help::Macro_LastModified;

our $HELP = {

        'last modified' => {
		title => 'last modified title',
		body => 'last modified body',
		fields => [
		],
		related => [
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
			{
				tag => 'date',
				namespace => 'Macro_D_date'
			},
		]
	},

};

1;
