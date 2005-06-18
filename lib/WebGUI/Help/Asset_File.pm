package WebGUI::Help::Asset_File;

our $HELP = {

        'file add/edit' => {
		title => 'file add/edit title',
		body => 'file add/edit body',
		fields => [
			{
				title => 'new file',
				description => 'new file description'
			},
			{
				title => 'current file',
				description => 'current file description'
			},
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'file template',
				namespace => 'Asset_File'
			},
		]
	},

        'file template' => {
		title => 'file template title',
		body => 'file template body',
		fields => [
		],
		related => [
			{
				tag => 'file add/edit',
				namespace => 'Asset_File'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

};

1;
