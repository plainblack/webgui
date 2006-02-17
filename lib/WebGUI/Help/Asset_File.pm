package WebGUI::Help::Asset_File;

our $HELP = {

        'file add/edit' => {
		title => 'file add/edit title',
		body => 'file add/edit body',
		fields => [
			{
				title => 'new file',
				description => 'new file description',
				namespace => 'Asset_File',
			},
			{
				title => 'current file',
				description => 'current file description',
				namespace => 'Asset_File',
			},
                        {
                                title => 'file template title',
                                description => 'file template description',
                                namespace => 'Asset_File',
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset',
			},
			{
				tag => 'file template',
				namespace => 'Asset_File',
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
				tag => 'asset template',
				namespace => 'Asset',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
			{
				tag => 'file add/edit',
				namespace => 'Asset_File',
			},
		]
	},

};

1;
