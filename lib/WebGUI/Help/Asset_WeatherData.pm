package WebGUI::Help::Asset_WeatherData;

our $HELP = {
	'weather data add/edit' => {
		title => 'weather data add/edit title',
		body => 'weather data add/edit body',
		isa => [
		],
		fields => [
			{
				title => 'partnerId',
				description => 'partnerId help',
				namespace => 'Asset_WeatherData',
			},
			{
				title => 'licenseKey',
				description => 'licenseKey help',
				namespace => 'Asset_WeatherData',
			},
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
		],
	},

	'weatherdata template' => {
		title => 'WeatherData template title',
		body => 'WeatherData template description',
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
				tag => 'weather data add/edit',
				namespace => 'Asset_WeatherData'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},

	'weatherdata asset template variables' => {
		private => 1,
		title => 'weatherdata asset template variables title',
		body => 'weatherdata asset template variables body',
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
