package WebGUI::i18n::English::Workflow_Activity_CacheEMSPrereqs;

our $I18N = {
	'activityName' => {
		message => q|Cache EMS Prerequisites|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'cache ems prereqs body' => {
		message => q|<p>This workflow activity caches all possible required events for an EMS.  When the activity is triggered, it will take the first EMS that is found in the system and then process the events for preqrequisites.  Since this process may take a very long time, it will process as many events as it can in one minute with a minimum of one complete event being processed.  Then it will pause and reque itself so that other activities can be processed.</p>|,
		lastUpdated => 0,
	},

};

1;
