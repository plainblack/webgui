package WebGUI::Help::Folder;

our $HELP = {

        'folder add/edit' => {
		title => 'folder add/edit title',
		body => 'folder add/edit body',
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
				tag => 'folder template',
				namespace => 'Folder'
			},
		]
	},

        'folder template' => {
		title => 'folder template title',
		body => 'folder template body',
		related => [
			{
				tag => 'folder add/edit',
				namespace => 'Folder'
			},
			{
				tag => 'template language',
				namespace => 'Template'
			},
		]
	},

};

1;
