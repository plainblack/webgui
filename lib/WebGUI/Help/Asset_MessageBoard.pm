package WebGUI::Help::Asset_MessageBoard;

our $HELP = {
	'message board add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => 'visitor cache timeout',
                                namespace => 'Asset_MessageBoard',
                                description => 'visitor cache timeout help',
				uiLevel => 8
                        },
                        {
                                title => '73',
                                namespace => 'Asset_MessageBoard',
                                description => '73 description'
                        },
		],
		related => [
			{
				tag => 'message board template',
				namespace => 'Asset_MessageBoard'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'message board template' => {
		title => '73',
		body => '74',
		fields => [
		],
		related => [
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	}
};

1;
