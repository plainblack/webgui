package WebGUI::Help::Asset_Poll;

our $HELP = {
	'poll add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'poll template',
				namespace => 'Asset_Poll'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},
	'poll template' => {
		title => '73',
		body => '74',
		related => [
			{
				tag => 'poll add/edit',
				namespace => 'Asset_Poll'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
