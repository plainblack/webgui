package WebGUI::Help::Asset;

our $HELP = {
	'asset fields' => {
		title => 'asset fields title',
		body => 'asset fields body',
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

        'snippet add/edit' => {
		title => 'snippet add/edit title',
		body => 'snippet add/edit body',
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},

};

1;
