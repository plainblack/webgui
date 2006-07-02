package WebGUI::i18n::English::Workflow_Activity_PurgeOldAssetRevisions;

our $I18N = {

	'topicName' => {
		message => q|Purge Old Asset Revisions|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'purge old asset revisions body' => {
		message => q|<p>This workflow activity will delete versions of assets that are older than the configured interval, unless the asset only has one approved version.  This can be used to save diskspace and keep the size of your database down.</p>
<p>The default version of WebGUI ships with a weekly Workflow to delete Assets older than 1 year old.  Disabling this Activity in the Workflow will keep versions forever.</p>|,
		lastUpdated => 0,
	},

};

1;
