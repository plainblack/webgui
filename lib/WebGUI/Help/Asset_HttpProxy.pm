package WebGUI::Help::Asset_HttpProxy;

our $HELP = {
	'http proxy add/edit' => {
		title => '10',
		body => '11',
		fields => [
                        {
                                title => '1',
                                description => '1 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '5',
                                description => '5 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '8',
                                description => '8 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '12',
                                description => '12 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => 'http proxy template title',
                                description => 'http proxy template title description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '6',
                                description => '6 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '418',
                                description => '418 description',
                                namespace => 'WebGUI',
                        },
                        {
                                title => '4',
                                description => '4 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '13',
                                description => '13 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '14',
                                description => '14 description',
                                namespace => 'Asset_HttpProxy',
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
		fields => [
		],
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
