package WebGUI::Help::DataForm;

our $HELP = {
	'data form add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'data form fields add/edit',
				namespace => 'DataForm'
			},
			{
				tag => 'data form list template',
				namespace => 'DataForm'
			},
			{
				tag => 'data form template',
				namespace => 'DataForm'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},
	'data form fields add/edit' => {
		title => '62',
		body => '72',
		related => [
			{
				tag => 'data form template',
				namespace => 'DataForm'
			},
			{
				tag => 'data form add/edit',
				namespace => 'DataForm'
			}
		]
	},
	'data form template' => {
		title => '82',
		body => '83',
		related => [
			{
				tag => 'data form fields add/edit',
				namespace => 'DataForm'
			},
			{
				tag => 'data form add/edit',
				namespace => 'DataForm'
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
		related => [
			{
				tag => 'data form add/edit',
				namespace => 'DataForm'
			}
		]
	},
};

1;
