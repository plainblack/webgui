package WebGUI::Help::Asset_Survey;

our $HELP = {
	'survey add/edit' => {
		title => '3',
		body => '4',
		fields => [
                        {
                                title => 'view template',
                                description => 'view template description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => 'response template',
                                description => 'response template description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => 'gradebook template',
                                description => 'gradebook template description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => 'overview template',
                                description => 'overview template description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '8',
                                description => '8 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '83',
                                description => '83 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '11',
                                description => '11 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '81',
                                description => '81 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '84',
                                description => '84 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '85',
                                description => '85 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '12',
                                description => '12 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '13',
                                description => '13 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => 'what next',
                                description => 'what next description',
                                namespace => 'Asset_Survey',
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'question add/edit',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'answer add/edit',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'survey template',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'survey template common vars',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'gradebook report template',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'survey response template',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'statistical overview report template',
				namespace => 'Asset_Survey'
			},
		]
	},
	'question add/edit' => {
		title => '17',
		body => 'question add/edit body',
		fields => [
                        {
                                title => '14',
                                description => '14 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '15',
                                description => '15 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '16',
                                description => '16 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '21',
                                description => '21 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => 'what next question',
                                description => 'what next question description',
                                namespace => 'Asset_Survey',
                        },
		],
		related => [
			{
				tag => 'survey add/edit',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'answer add/edit',
				namespace => 'Asset_Survey'
			},
		]
	},
	'answer add/edit' => {
		title => '18',
		body => 'answer add/edit body',
		fields => [
                        {
                                title => '19',
                                description => '19 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '20',
                                description => '20 description',
                                namespace => 'Asset_Survey',
                        },
                        {
                                title => '21',
                                description => '21 description',
                                namespace => 'Asset_Survey',
                        },
		],
		related => [
			{
				tag => 'question add/edit',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Asset_Survey'
			},
		]
	},
	'survey template' => {
		title => '88',
		body => '89',
		fields => [
		],
		related => [
			{
				tag => 'survey template common vars',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
	'survey template common vars' => {
		title => '90',
		body => '91',
		fields => [
		],
		related => [
			{
				tag => 'survey template',
				namespace => 'Asset_Survey'
			}
		]
	},
	'gradebook report template' => {
		title => '1087',
		body => '1088',
		fields => [
		],
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'survey template',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'survey template common vars',
				namespace => 'Asset_Survey'
			}
		]
	},
	'survey response template' => {
		title => '1089',
		body => '1090',
		fields => [
		],
		related => [
			{
				tag => 'survey template common vars',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Asset_Survey'
			}
		]
	},
	'statistical overview report template' => {
		title => '1091',
		body => '1092',
		fields => [
		],
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'survey template common vars',
				namespace => 'Asset_Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Asset_Survey'
			}
		]
	},
};

1;
