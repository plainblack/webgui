package WebGUI::Help::Asset;

our $HELP = {
	'asset add/edit' => {
		title => 'asset add/edit title',
		body => 'asset add/edit body',
		related => [
		]
	},
        'asset macros' => {
		title => 'asset macros title',
		body => 'asset macros body',
		related => [
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			},
		]
	},
};

1;
