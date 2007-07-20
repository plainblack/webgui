package WebGUI::Help::Asset_WeatherData;

our $HELP = {
	'weatherdata template' => {
		title => 'WeatherData template title',
		body => '',
		isa => [
			{
				tag => "weatherdata asset template variables",
				namespace => 'Asset_WeatherData'
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'ourLocations.loop',
		            'variables' => [
		                             {
		                               'name' => 'query'
		                             },
		                             {
		                               'name' => 'cityState'
		                             },
		                             {
		                               'name' => 'sky'
		                             },
		                             {
		                               'name' => 'tempF'
		                             },
		                             {
		                               'name' => 'iconUrl'
		                             }
		                           ]
		          }
		],
		related => [
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},

	'weatherdata asset template variables' => {
		private => 1,
		title => 'weatherdata asset template variables title',
		body => '',
		isa => [
			{
				tag => "wobject template variables",
				namespace => 'Asset_Wobject'
			},
		],
		fields => [
		],
		variables => [
			{
			'name' => 'templateId'
			},
			{
			'name' => 'locations'
			},
		],
		related => [
		],
	},

};

1;
