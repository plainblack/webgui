package WebGUI::Help::Survey;

our $HELP = {
	'survey add/edit' => {
		title => '3',
		body => '4',
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'survey template',
				namespace => 'Survey'
			},
			{
				tag => 'survey template common vars',
				namespace => 'Survey'
			},
			{
				tag => 'gradebook report template',
				namespace => 'Survey'
			},
			{
				tag => 'survey response template',
				namespace => 'Survey'
			},
			{
				tag => 'statistical overview report template',
				namespace => 'Survey'
			},
		]
	},
	'survey template' => {
		title => '88',
		body => '89',
		related => [
			{
				tag => 'survey template common vars',
				namespace => 'Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Survey'
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
		related => [
			{
				tag => 'survey template',
				namespace => 'Survey'
			}
		]
	},
	'gradebook report template' => {
		title => '1087',
		body => '1088',
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'survey template',
				namespace => 'Survey'
			},
			{
				tag => 'survey template common vars',
				namespace => 'Survey'
			}
		]
	},
	'survey response template' => {
		title => '1089',
		body => '1090',
		related => [
			{
				tag => 'survey template common vars',
				namespace => 'Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Survey'
			}
		]
	},
	'statistical overview report template' => {
		title => '1091',
		body => '1092',
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'survey template common vars',
				namespace => 'Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Survey'
			}
		]
	},
};

1;
