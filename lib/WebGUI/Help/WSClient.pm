package WebGUI::Help::WSClient;

our $HELP = {
	'ws client add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'ws client template',
				namespace => 'WSClient'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},
	'ws client template' => {
		title => '72',
		body => '73',
		related => [
			{
				tag => 'ws client add/edit',
				namespace => 'WSClient'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
