package WebGUI::Help::Asset_HttpProxy;

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
				namespace => 'Asset_HttpProxy'
			},
			{
				tag => 'content filtering',
				namespace => 'WebGUI'
			},
		]
	},

	'http proxy template' => {
		title => 'http proxy template title',
		body => 'http proxy template body',
		related => [
			{
				tag => 'http proxy add/edit',
				namespace => 'Asset_HttpProxy'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

};

1;
