package WebGUI::Help::Macro_AOIRank;

our $HELP = {

        'aoi rank' => {
		title => 'aoi rank title',
		body => 'aoi rank body',
		fields => [
		],
		related => [
			{
				tag => 'metadata manage',
				namespace => 'Asset'
			},
			{
				tag => 'settings',
				namespace => 'WebGUI'
			},
			{
				tag => 'aoi hits',
				namespace => 'Macro_AOIHits',
			},
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
		]
	},

};

1;
