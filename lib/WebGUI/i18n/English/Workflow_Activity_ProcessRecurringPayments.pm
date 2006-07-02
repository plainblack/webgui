package WebGUI::i18n::English::Workflow_Activity_ProcessRecurringPayments;

our $I18N = {

	'activityName' => {
		message => q|Process Recurring Payments|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'process recurring payments body' => {
		message => q|<p>This workflow activity will process all recurring transactions (payments) in the Commerce system that are complete at the time the Activity is executed.  When the Activity is through with all those payments, a email with the details of all transactions is sent to the user configured in the Settings to receive them.</p>|,
		lastUpdated => 0,
	},

};

1;
