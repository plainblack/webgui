package WebGUI::i18n::English::Workflow_Cron;

our $I18N = { 
	'day of week help' => {
		message => q|Which day of the week do you want this workflow triggered? The range is between 0 and 6 where 0 is Sunday. You can specify a specific day like "0" or "2". You may also specify all days of the week by "*". And finally you can specify a list of days of the week like "1,5,6".|,
		context => q|the hover help for the month of year field|,
		lastUpdated => 0,
	},

	'day of week' => {
		message => q|Day of Week|,
		context => q|The day of week field.|,
		lastUpdated => 0,
	},

	'month of year help' => {
		message => q|Which month of the year do you want this workflow triggered? The range is between 1 and 31. You can specify a specific month like "2" or 12". You may also specify all months by "*". You can specify intervals like "*/3" (every 3 months). And finally you can specify a list of months like "1,5,11".|,
		context => q|the hover help for the month of year  field|,
		lastUpdated => 0,
	},

	'month of year' => {
		message => q|Month of Year|,
		context => q|The month field.|,
		lastUpdated => 0,
	},

	'day of month help' => {
		message => q|Which day of the month do you want this workflow triggered? The range is between 1 and 31. You can specify a specific day like "2" or 12". You may also specify all days by "*". You can specify intervals like "*/3" (every 3 days). And finally you can specify a list of days like "1,5,11".|,
		context => q|the hover help for the day of month field|,
		lastUpdated => 0,
	},

	'day of month' => {
		message => q|Day of Month|,
		context => q|The day field.|,
		lastUpdated => 0,
	},

	'hour of day help' => {
		message => q|Which hour of the day do you want this workflow triggered? The range is between 0 and 23. You can specify a specific hour like "0" or 12". You may also specify all hours by "*". You can specify intervals like "*/3" (every 3 hours). And finally you can specify a list of hours like "1,5,17,21".|,
		context => q|the hover help for the hour of day field|,
		lastUpdated => 0,
	},

	'hour of day' => {
		message => q|Hour of Day|,
		context => q|The hour field.|,
		lastUpdated => 0,
	},

	'minute of hour help' => {
		message => q|Which minute of the hour do you want this workflow triggered? The range is between 0 and 59. You can specify a specific minute like "0" or 12". You may also specify all minutes by "*". You can specify intervals like "*/3" (every 3 minutes). And finally you can specify a list of minutes like "1,5,17,24".|,
		context => q|the hover help for the minute of hour field|,
		lastUpdated => 0,
	},

	'minute of hour' => {
		message => q|Minute of Hour|,
		context => q|The minute field.|,
		lastUpdated => 0,
	},

	'run once help' => {
		message => q|If this is set to yes, then the task will be executed at the scheduled time, and then will delete itself.|,
		context => q|the hover help for the run once field|,
		lastUpdated => 0,
	},

	'run once' => {
		message => q|Run Once?|,
		context => q|Yes or no question asking the user if this cron job should delete itself after the first execution.|,
		lastUpdated => 0,
	},

	'is enabled help' => {
		message => q|If this is set to yes, then the workflow will be kicked off at the scheduled time.|,
		context => q|the hover help for the enabled field|,
		lastUpdated => 0,
	},

	'is enabled' => {
		message => q|Is Enabled?|,
		context => q|Yes or no question asking the user if this cron job is enabled.|,
		lastUpdated => 0,
	},

	'workflow help' => {
		message => q|Choose a workflow that you wish to execute at the scheduled time.|,
		context => q|the hover help for the workflow field|,
		lastUpdated => 0,
	},

	'workflow' => {
		message => q|Workflow|,
		context => q|A label indicating to the user that they should select a workflow.|,
		lastUpdated => 0,
	},

	'title help' => {
		message => q|A human readable label to easily identify what this task does.|,
		context => q|the hover help for the title field|,
		lastUpdated => 0,
	},

	'title' => {
		message => q|Title|,
		context => q|A human readable label to identify a cron job.|,
		lastUpdated => 0,
	},

	'priority help' => {
		message => q|This determines the priority level of the workflow to be executed. Normally this should be left at "medium". If the workflow needs urgent execcution, then set it to "high". If it's a maintenance task and can be put off until the server is less busy, then set it to "low"|,
		context => q|the hover help for the priority|,
		lastUpdated => 0,
	},

	'priority' => {
		message => q|Priority|,
		context => q|A level of urgency for a workflow to be executed under.|,
		lastUpdated => 0,
	},

	'low' => {
		message => q|Low|,
		context => q|The least amount of priority.|,
		lastUpdated => 0,
	},

	'high' => {
		message => q|High|,
		context => q|The greatest priority.|,
		lastUpdated => 0,
	},

	'medium' => {
		message => q|Medium|,
		context => q|Mid range priority.|,
		lastUpdated => 0,
	},

	'enabled' => {
		message => q|Enabled|,
		context => q|A label to indicate that the cron job is ready to run.|,
		lastUpdated => 0,
	},

	'disabled' => {
		message => q|Disabled|,
		context => q|A label to indicate that the cron job is not ready to run.|,
		lastUpdated => 0,
	},

	'id' => {
		message => q|Task ID|,
		context => q|a label for the unique id representing the task|,
		lastUpdated => 0,
	},

	'manage tasks' => {
		message => q|Manage all tasks.|,
		context => q|clicking on this text linked will show the user a list of all cron jobs|,
		lastUpdated => 0,
	},

	'add a new task' => {
		message => q|Add a new task.|,
		context => q|clicking on this text linked will add a new cron job|,
		lastUpdated => 0,
	},

	'topicName' => {
		message => q|Scheduler|,
		context => q|The title of the cron/scheduler interface.|,
		lastUpdated => 0,
	},

	'are you sure you wish to delete this scheduled task' => {
		message => q|Are you certain you wish to delete this scheduled task?|,
		context => q|prompt when a user is about to delete the cron job|,
		lastUpdated => 0,
	},

};

1;
