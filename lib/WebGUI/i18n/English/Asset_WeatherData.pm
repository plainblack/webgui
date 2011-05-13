package WebGUI::i18n::English::Asset_WeatherData;
use strict;

our $I18N = {
	'you need a weather.com key' => {
		message => q|Click here to register with weather.com for the free Weather XML Data Feed, which you need to use this asset.|,
		lastUpdated => 0,
	},

	'licenseKey help' => {
		message => q|You received this key in the email weather.com sent you after registering for the Weather XML Data Feed.|,
		lastUpdated => 0,
	},

	'licenseKey' => {
		message => q|Weather.com License Key|,
		lastUpdated => 0,
	},

	'partnerId' => {
		message => q|Weather.com Partner Id|,
		lastUpdated => 0,
	},

	'partnerId help' => {
		message => q|You received this id in the email weather.com sent you after registering for the Weather XML Data Feed.|,
		lastUpdated => 0,
	},

	'Current Weather Conditions Template to use' => {
		message => q|Current Weather Conditions Template to use|,
		lastUpdated => 1133619940,
	},

	'Template' => {
		message => q|Template|,
		lastUpdated => 1133619940,
	},

	'Your list of default weather locations' => {
		message => q{Your list of default weather locations, each on its own line.  Usage: City, ST || Zip Code || City, Country},
		lastUpdated => 1172425406,
	},

	'Default Locations' => {
		message => q|Default Location(s)|,
		lastUpdated => 1133619940,
	},

	'assetName' => {
		message => q|WeatherData|,
		lastUpdated => 1133619940,
	},

	'WeatherData template title' => {
		message => q|WeatherData Template|,
		lastUpdated => 1133619940,
	},

	'ourLocations.loop' => {
		message => q|A loop containing weather information for all configured user locations.|,
		lastUpdated => 1149565151,
	},

	'query' => {
		message => q|The requested location.|,
		lastUpdated => 1149565151,
	},

	'cityState' => {
		message => q|The city and state returned from the NOAA.  This will probably be the same as <b>query</b>.|,
		lastUpdated => 1149565151,
	},

	'sky' => {
		message => q|The condition of the sky, i.e. clear, sunny, cloudy, etc.|,
		lastUpdated => 1149565151,
	},

	'tempF' => {
		message => q|The temperature in degrees Farenheit.|,
		lastUpdated => 1149565151,
	},

	'iconUrl' => {
		message => q|The URL to an icon that represents visually the condition of the sky.|,
		lastUpdated => 1149565151,
	},

	'templateId' => {
		message => q|The ID of the template that will be used to display this Asset.|,
		lastUpdated => 1167972308,
	},

	'locations' => {
		message => q|The list of locations entered by the user.|,
		lastUpdated => 1167972310,
	},

	'weatherdata asset template variables title' => {
		message => q|WeatherData Asset Template Variables|,
		lastUpdated => 1167972337
	},

	'cache timeout help' => {
		message => q|How long should lookups for each location be cached internally?|,
		context => q|Template variable help|,
		lastUpdated => 1229493261,
	},

};

1;
