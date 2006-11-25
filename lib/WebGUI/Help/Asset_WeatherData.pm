package WebGUI::Help::Asset_WeatherData;

our $HELP = {
	'weather data add/edit' => {
		title => 'weather data add/edit title',
		body => 'weather data add/edit body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit"
			},
		],
		fields => [
			{
				title => 'Default Locations',
				description => 'Your list of default weather locations',
				namespace => 'Asset_WeatherData',
			},
		],
		related => [
			{
				tag => 'weatherdata template',
				namespace => 'Asset_WeatherData'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
		],
	},

	'weatherdata template' => {
		title => 'WeatherData template title',
		body => 'WeatherData template description',
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
				tag => 'weather data add/edit',
				namespace => 'Asset_WeatherData'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
};

1;
