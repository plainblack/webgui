package WebGUI::Help::WSClient;

our $HELP = {
	'web services client add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'web services client template',
				namespace => 'WSClient'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'web services client template' => {
		title => '72',
		body => '73',
		related => [
			{
				tag => 'web services client add/edit',
				namespace => 'WSClient'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
};

1;
