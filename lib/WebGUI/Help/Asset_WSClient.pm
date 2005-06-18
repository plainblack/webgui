package WebGUI::Help::Asset_WSClient;

our $HELP = {
	'ws client add/edit' => {
		title => '61',
		body => '71',
		fields => [
		],
		related => [
			{
				tag => 'ws client template',
				namespace => 'Asset_WSClient'
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
		fields => [
		],
		related => [
			{
				tag => 'ws client add/edit',
				namespace => 'Asset_WSClient'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
