package WebGUI::Help::SiteMap;

our $HELP = {
	'site map add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'site map template',
				namespace => 'SiteMap'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'site map template' => {
		title => '72',
		body => '73',
		related => [
			{
				tag => 'site map add/edit',
				namespace => 'SiteMap'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
};

1;
