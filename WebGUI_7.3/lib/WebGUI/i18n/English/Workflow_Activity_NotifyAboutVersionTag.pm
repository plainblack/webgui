package WebGUI::i18n::English::Workflow_Activity_NotifyAboutVersionTag;

our $I18N = {
	'activityName' => {
		message => q|Notify About Version Tag|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'notify about version tag body' => {
		message => q|<p>This workflow activity will send out an email with information about a version tag.  The message can be sent to either the tag's committer, the tag's owner, or a group responsible for the tag.  The message will include fixed text configured in this activity as well as comments from the tag and the URL to the first asset found in the tag.</p>|,
		lastUpdated => 0,
	},

};

1;
