package WebGUI::Help::File;

our $HELP = {

        'file add/edit' => {
		title => 'file add/edit title',
		body => 'file add/edit body',
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'file template',
				namespace => 'File'
			},
		]
	},

        'file template' => {
		title => 'file template title',
		body => 'file template body',
		related => [
			{
				tag => 'file add/edit',
				namespace => 'File'
			},
			{
				tag => 'template language',
				namespace => 'Template'
			},
		]
	},

};

1;
