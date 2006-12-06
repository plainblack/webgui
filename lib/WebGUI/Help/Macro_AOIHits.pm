package WebGUI::Help::Macro_AOIHits;

our $HELP = {

        'aoi hits' => {
		title => 'aoi hits title',
		body => 'aoi hits body',
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
				tag => 'aoi rank',
				namespace => 'Macro_AOIRank',
			},
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
		]
	},

};

1;
