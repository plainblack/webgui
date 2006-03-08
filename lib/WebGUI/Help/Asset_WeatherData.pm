package WebGUI::Help::Asset_WeatherData;

our $HELP = {
	'weather data add/edit' => {
		title => 'weather data add/edit title',
		body => 'weather data add/edit body',
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
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		],
	},
	'weatherdata template' => {
		title => 'WeatherData template title',
		body => 'WeatherData template description',
		fields => [
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
