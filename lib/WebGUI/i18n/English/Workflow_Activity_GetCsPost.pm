package WebGUI::i18n::English::Workflow_Activity_GetCsPost;

our $I18N = {
	'topicName' => {
		message => q|Get Collaboration System Posts from Email|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'get cs post body' => {
		message => q|<p>This workflow activity will fetch emails to the email box configured for the Collaboration System and create threads and posts inside the CS from them.  Because this process could take a long time, based on the number of emails that have queued up, the activity will stop after one minute.</p>|,
		lastUpdated => 0,
	},

};

1;
