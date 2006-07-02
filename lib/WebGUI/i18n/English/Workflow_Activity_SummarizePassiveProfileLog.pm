package WebGUI::i18n::English::Workflow_Activity_SummarizePassiveProfileLog;

our $I18N = {
	'activityName' => {
		message => q|Summarize Passive Profile Log|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'summarize passive profile log body' => {
		message => q|<p>This workflow activity will summarize passive profiling data for all users except for Visitor and then delete their previous passive log.  If passive profiling is disabled in the site settings, the summarization will not be done.</p>|,
		lastUpdated => 0,
	},

};

1;
