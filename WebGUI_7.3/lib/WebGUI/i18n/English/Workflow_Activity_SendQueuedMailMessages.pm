package WebGUI::i18n::English::Workflow_Activity_SendQueuedMailMessages;

our $I18N = {
	'activityName' => {
		message => q|Send Queued Mail Messages|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'send queued mail messages body' => {
		message => q|<p>This workflow activity will process queued emails.  If an email fails to be sent, then it will be requeued to be sent later.  Because this process could take a long time, based on the number of emails that have queued up, this activity will stop after one minute.</p>|,
		lastUpdated => 0,
	},

};

1;
