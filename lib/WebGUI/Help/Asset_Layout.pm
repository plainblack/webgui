package WebGUI::Help::Asset_Layout;

our $HELP = {

        'layout add/edit' => {
		title => 'layout add/edit title',
		body => 'layout add/edit body',
		fields => [
                        {
                                title => 'Template',
                                description => 'Template description',
                                namespace => 'Asset_Layout',
                        },
                        {
                                title => '498',
                                description => '498 description',
                                namespace => 'Asset_FilePile',
                        },
                        {
                                title => 'Assets to Hide',
                                description => 'Assets to Hide description',
                                namespace => 'Asset_Layout',
                        },
		],
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
