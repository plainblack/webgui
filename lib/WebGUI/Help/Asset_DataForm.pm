package WebGUI::Help::Asset_DataForm;

our $HELP = {
	'data form add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => '16',
                                description => '16 description'
                        },
                        {
                                title => '74',
                                description => '74 description'
                        },
                        {
                                title => '913',
                                description => '913 description'
                        },
                        {
                                title => '81',
                                description => '81 description'
                        },
                        {
                                title => '81',
                                description => '81 description'
                        },
                        {
                                title => '87',
                                description => '87 description'
                        },
                        {
                                title => 'defaultView',
                                description => 'defaultView description'
                        },
                        {
                                title => '744',
                                description => '744 description'
                        },
                        {
                                title => '76',
                                description => '76 description'
                        },
                        {
                                title => '105',
                                description => '105 description'
                        },
                        {
                                title => '86',
                                description => '86 description'
                        },
                        {
                                title => '76',
                                description => '76 description'
                        },
                ],
		related => [
			{
				tag => 'data form fields add/edit',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form list template',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form template',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},
	'data form fields add/edit' => {
		title => '62',
		body => '72',
		fields => [
		],
		related => [
			{
				tag => 'data form template',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form add/edit',
				namespace => 'Asset_DataForm'
			}
		]
	},
	'data form template' => {
		title => '82',
		body => '83',
		fields => [
		],
		related => [
			{
				tag => 'data form fields add/edit',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form add/edit',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
	'data form list template' => {
		title => '88',
		body => '89',
		fields => [
		],
		related => [
			{
				tag => 'data form add/edit',
				namespace => 'Asset_DataForm'
			}
		]
	},
};

1;
