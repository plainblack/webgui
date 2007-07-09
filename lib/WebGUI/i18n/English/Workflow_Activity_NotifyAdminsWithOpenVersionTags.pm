package WebGUI::i18n::English::Workflow_Activity_NotifyAdminsWithOpenVersionTags;  ##Be sure to change the package name to match the filename

our $I18N = { ##hashref of hashes
	'days left open label' => { 
		message => q|Days Left Open|,
		lastUpdated => 0,
		context => q||,
	},

	'days left open hoverhelp' => { 
		message => q|The number of days a version tag needs to be left open before a notification is sent to its user.|,
		lastUpdated => 0,
		context => q||,
	},

	'email subject' => { 
		message => q|Uncommitted version tag%s on %s|,
		lastUpdated => 0,
		context => q||,
	},

	'email message' => { 
		message => q|You have %d uncommitted version tag%s on %s.<p/>Please <a href="http://%s/?op=manageVersions">process them</a>.<p/>Thank you.|,
		lastUpdated => 0,
		context => q||,
	},

	'notify admins with open version tags body' => { 
		message => q|<p>This workflow activity sends out a notification to all users who have an uncommitted tag.  It only does this if the version tag is empty.  The amount of time a version tag is empty is configurable, with a default of 3 days.</p>|,
		lastUpdated => 1184020073,
		context => q||,
	},

	#If the help file documents an Asset, it must include an assetName key
	#If the help file documents an Macro, it must include an macroName key
	#If the help file documents a Workflow Activity, it must include an activityName key
	#If the help file documents a Template Parser, it must include an templateParserName key
	#For all other types, use topicName
	'activityName' => {
		message => q|Notify Admins of Old Version Tags|,
		lastUpdated => 1131394072,
	},

};

1;
