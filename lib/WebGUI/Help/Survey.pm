package WebGUI::Help::Survey;

our $HELP = {
	'survey add/edit' => {
		title => '3',
		body => '4',
		related => [
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
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
				namespace => 'WebGUI'
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
};

1;
