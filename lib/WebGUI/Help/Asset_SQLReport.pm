package WebGUI::Help::Asset_SQLReport;

our $HELP = {
	'sql report add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'sql report template',
				namespace => 'Asset_SQLReport'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
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
				namespace => 'Asset_SQLReport'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
