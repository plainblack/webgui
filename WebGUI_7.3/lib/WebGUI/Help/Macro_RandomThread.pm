package WebGUI::Help::Macro_RandomThread;

our $HELP = {
        'random thread' => {
		title => 'random thread title',
		body => 'random thread body',
		fields => [
		],
		related => [
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
			{
				tag => 'macros list',
				namespace => 'Macros'
			},
			{
				tag => 'random asset proxy',
				namespace => 'Macro_RandomAssetProxy'
			},
			{
				tag => 'collaboration post list template variables',
				namespace => 'Asset_Collaboration'
			}
		]
	},

};

1;
