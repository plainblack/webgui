package WebGUI::i18n::English::Workflow_Activity_RequestApprovalForVersionTag;

our $I18N = {

	'topicName' => {
		message => q|Request Approval For Version Tag|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'request approval for version tag body' => {
		message => q|<p>This workflow activity is used by WebGUI's version control.  It is used to require approval for a version tag to be committed.</p>
<p>When a user commits a version tag, an email is sent out to all members of a user selected group.  The email contains all comments from the committer along with a URL to manage the committed version tag.  The first user to respond to the email can either approve or deny the commit.  If the user approves the version tag, it will be committed the next time this Activity is called.  If the user denies the version tag, then a selectable Workflow will be called.</p>
<p>One of WebGUI's default Workflows includes this Activity to implement basic authorization for committing versions.  In this Workflow, if the commit is denied, then the version tag is unlocked and the committer is notified that the commit was denied with comments as to why.</p>|,
		lastUpdated => 0,
	},

};

1;
