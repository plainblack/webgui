package WebGUI::i18n::English::Workflow_Activity_CleanLoginHistory;
use strict;

our $I18N = {
	'age to delete help' => {
		message => q|After what period of time is it ok to start deleteing entries from the user login history?|,
		context => q|the hover help for the age to delete field|,
		lastUpdated => 0,
	},

	'age to delete' => {
		message => q|Age To Delete|,
		context => q|a label how old we should allow the login history to get|,
		lastUpdated => 0,
	},

	'activityName' => {
		message => q|Clean Login History|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},
"retain last login is enabled" => {
		message => q|Always Retain Last Login Record|,
		context => q|user login record retention|,
		lastUpdated => 0,
	},
        "retain last login is enabled help" => {
		message => q|Do not delete the user's very last login record even if it is older than age to delete.  Useful to determine if the login id has not been used on your site because it has been set up manually or has been transferred from another site.|,
		context => q|Explain user login record retention|,
		lastUpdated => 0,
	},
};

1;
