package WebGUI::Help::Layout;

our $HELP = {

        'layout add/edit' => {
		title => 'layout add/edit title',
		body => 'layout add/edit body',
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
				tag => 'layout template',
				namespace => 'Layout'
			},
		]
	},

        'layout template' => {
		title => 'layout template title',
		body => 'layout template body',
		related => [
			{
				tag => 'layout add/edit',
				namespace => 'Layout'
			},
			{
				tag => 'template language',
				namespace => 'Template'
			},
		]
	},

};

1;
