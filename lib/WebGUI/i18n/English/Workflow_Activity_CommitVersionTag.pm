package WebGUI::i18n::English::Workflow_Activity_CommitVersionTag;

our $I18N = {

	'activityName' => {
		message => q|Commit Version Tag|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'commit version tag body' => {
		message => q|<p>This workflow activity commits a version tag.  It should be used as the last step in any workflow dealing with committing version tags.  For example, if you built a workflow that required someone else to authorize the committing of a version tag, this activity would be the last step in the workflow and its execution would depend on the authorization actually heppening and being positive.</p>|,
		lastUpdated => 0,
	},

};

1;
