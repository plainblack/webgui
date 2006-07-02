package WebGUI::i18n::English::Workflow_Activity_PurgeOldTrash;

our $I18N = {

	'activityName' => {
		message => q|Purge Old Trash|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'purge old trash body' => {
		message => q|<p>This workflow activity will delete assets from the trash that are older than the configured interval, unless the asset only has one approved version.</p>
<p>The default version of WebGUI ships with a weekly Workflow to delete Trash older than 30 days old.  Disabling this Activity in the Workflow will keep Assets in the Trash forever.</p>|,
		lastUpdated => 0,
	},

};

1;
