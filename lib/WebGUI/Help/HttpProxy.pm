package WebGUI::Help::HttpProxy;

our $HELP = {
	'http proxy add/edit' => {
		title => '10',
		body => '11',
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Wobject'
			},
			{
				tag => 'http proxy template',
				namespace => 'HttpProxy'
			},
		]
	},

	'http proxy template' => {
		title => 'http proxy template title',
		body => 'http proxy template body',
		related => [
			{
				tag => 'http proxy add/edit',
				namespace => 'HttpProxy'
			},
			{
				tag => 'template language',
				namespace => 'Template'
			},
		]
	},

};

1;
