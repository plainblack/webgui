package WebGUI::Help::Asset_Layout;

our $HELP = {

        'layout add/edit' => {
		title => 'layout add/edit title',
		body => 'layout add/edit body',
		fields => [
                        {
                                title => 'layout template title',
                                description => 'template description',
                                namespace => 'Asset_Layout',
                        },
                        {
                                title => '498',
                                description => '498 description',
                                namespace => 'Asset_FilePile',
                        },
                        {
                                title => 'assets to hide',
                                description => 'assets to hide description',
                                namespace => 'Asset_Layout',
				uiLevel => 9,
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'layout template',
				namespace => 'Asset_Layout'
			},
		]
	},

        'layout template' => {
		title => 'layout template title',
		body => 'layout template body',
		fields => [
		],
		related => [
			{
				tag => 'layout add/edit',
				namespace => 'Asset_Layout'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

};

1;
