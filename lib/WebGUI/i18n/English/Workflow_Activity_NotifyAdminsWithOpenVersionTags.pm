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

	'activityName' => {
		message => q|Notify Admins of Old Version Tags|,
		lastUpdated => 1131394072,
	},

};

1;
