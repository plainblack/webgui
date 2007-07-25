package WebGUI::i18n::English::Workflow_Activity_TrashClipboard;

our $I18N = {
	'trash after help' => {
		message => q|How long should WebGUI let content sit in the clipboard before moving it to the trash?|,
		context => q|the hover help for the trash after field|,
		lastUpdated => 0,
	},

	'trash after' => {
		message => q|Trash After|,
		context => q|a label indicating how long content should sit in the clipboard|,
		lastUpdated => 0,
	},

	'activityName' => {
		message => q|Empty Clipboard to Trash|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'trash clipboard body' => {
		message => q|<p>This workflow activity will move all assets from the Clipboard to the Trash after they have been in the Clipboard for the specified interval, if those Assets are committed.  Uncommitted Assets will stay in the Clipboard until after they are committed <i>and</i> they are older than the interval.</p>
<p>WebGUI ships with a default Workflow that moves all assets from the Clipboard to the Trash if they have been in the Clipboard for 30 days.</p>|,
		lastUpdated => 1173117358,
	},

};

1;
