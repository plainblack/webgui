package WebGUI::i18n::English::Workflow_Activity_TrashExpiredEvents;

our $I18N = {

	'activityName' => {
		message => q|Trash Expired Events|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'trash expired events body' => {
		message => q|<p>This workflow activity will move all Event assets to the Trash after a user defined interval has passed from their end date.</p>
<p>The default interval is 30 days.</p>|,
		lastUpdated => 0,
	},

	'trash after' => {
		message => q|Trash After|,
		lastUpdated => 1165731581,
		context=> q|a label for the workflow activity property that sets how long old events stick around|
	},

	'trash after help' => {
		message => q|How long should old events stay in the calendar before being trashed?|,
		lastUpdated => 1165731583,
		context=> q|hover help for the trash after field|
	},



};

1;
