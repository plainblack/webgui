package WebGUI::Help::Asset_Folder;

our $HELP = {

        'folder add/edit' => {
		title => 'folder add/edit title',
		body => 'folder add/edit body',
		fields => [
                        {
                                title => 'visitor cache timeout',
                                namespace => 'Asset_Folder',
                                description => 'visitor cache timeout help'
                        },
                        {
                                title => 'folder template title',
                                description => 'folder template description',
				namespace => 'Asset_Folder',
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset',
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Asset_Wobject',
			},
			{
				tag => 'folder template',
				namespace => 'Asset_Folder',
			},
		]
	},

        'folder template' => {
		title => 'folder template title',
		body => 'folder template body',
		fields => [
		],
		related => [
			{
				tag => 'folder add/edit',
				namespace => 'Asset_Folder',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

};

1;
