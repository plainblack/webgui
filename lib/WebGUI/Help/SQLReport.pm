package WebGUI::Help::SQLReport;

our $HELP = {
	'sql report add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'sql report template',
				namespace => 'SQLReport'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'sql report template' => {
		title => '72',
		body => '73',
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'sql report add/edit',
				namespace => 'SQLReport'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
};

1;
