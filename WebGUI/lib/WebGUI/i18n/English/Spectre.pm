package WebGUI::i18n::English::Spectre;  ##Be sure to change the package name to match the filename
use strict;

our $I18N = { ##hashref of hashes
	'spectre' => {
		message => q|Spectre|,
		lastUpdated => 0,
		context => q||,
	},

	'running' => {
		message => q|Spectre is running.|,
		lastUpdated => 0,
		context => q|let the user know that spectre's off|
	},

	'not running' => {
		message => q|Spectre is not running.|,
		lastUpdated => 0,
		context => q|let the user know that spectre's off|
	},

	'workflow status error' => {
		message => q|Spectre is running, but there was an error getting the workflow status.|,
		lastUpdated => 0,
		context => q||,
	},

	'cron status error' => {
		message => q|Spectre is running, but there was an error getting the cron status.|,
		lastUpdated => 0,
		context => q||,
	},

	'workflow header' => {
		message => q|There are <a href="%s">%d workflows</a>.<br/>|,
		lastUpdated => 0,
		context => q||,
	},

	'cron header' => {
		message => q|There are <a href="%s">%d scheduled tasks</a>|,
		lastUpdated => 0,
		context => q||,
	},

	#If the help file documents an Asset, it must include an assetName key
	#If the help file documents an Macro, it must include an macroName key
	#If the help file documents a Workflow Activity, it must include an activityName key
	#If the help file documents a Template Parser, it must include an templateParserName key
	#For all other types, use topicName
	'assetName' => {
		message => q|This should not matter...?|,
		lastUpdated => 1131394072,
	},

};

1;
