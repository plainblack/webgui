package WebGUI::Help::Asset_Survey;

our $HELP = {
	'survey add/edit' => {
		title => '3',
		body => '4',
		fields => [
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
		],
		related => [
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
