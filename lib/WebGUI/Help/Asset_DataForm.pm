package WebGUI::Help::Asset_DataForm;

our $HELP = {
	'data form add/edit' => {
		title => '61',
		body => '71',
		fields => [
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
