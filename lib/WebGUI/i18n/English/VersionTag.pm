package WebGUI::i18n::English::VersionTag;

our $I18N = {
	'export version tag to html' => {
		message => q|Export Version Tag To HTML|,
		context => q|the title of the workflow activity of the same name|,
		lastUpdated => 0 
	},

	'back to home' => {
		message => q|Back to home.|,
		lastUpdated => 0 
	},

	'version tags' => {
		message => q|Version Tags|,
		lastUpdated => 0 
	},

	'commit accepted' => {
		message => q|Your tag has been submitted for processing and commit. It may take some time before it appears live on the site. Where would you like to go next?|,
		lastUpdated => 0,
		context => q|label on the manage revisions in tag page during the approval process|
	},

	'comments' => {
		message => q|Comments|,
		lastUpdated => 0,
		context => q|label on the manage revisions in tag page during the approval process|
	},

	'comments help' => {
		message => q|Attach any comments or feedback to this tag that you wish. They will be available to anyone looking at this tag throughout the publish and approval process, as well as in the future as reference.|,
		lastUpdated => 0,
		context => q|hover help for the comments field|
	},

	'comments description commit' => {
		message => q|Attach any comments or feedback to this tag that you wish. They will be available to anyone looking at this tag in the future as reference.|,
		lastUpdated => 0,
		context => q|hover help for the comments field|
	},

	'deny' => {
		message => q|Deny|,
		lastUpdated => 0,
		context => q|label on the manage revisions in tag page during the approval process|
	},

	'approve' => {
		message => q|Approve|,
		lastUpdated => 0,
		context => q|label on the manage revisions in tag page during the approval process|
	},

	'approve/deny' => {
		message => q|Approve/Deny|,
		lastUpdated => 0,
		context => q|label on the manage revisions in tag page during the approval process|
	},

	'approve/deny help' => {
		message => q|Do you wish to approve or deny this tag?|,
		lastUpdated => 0,
		context => q|hover help for the approve/deny field|
	},

	'tag committer' => {
		message => q|Tag Committer|,
		lastUpdated => 0,
		context => q|label in the notify about version tag activity|
	},

	'tag creator' => {
		message => q|Tag Creator|,
		lastUpdated => 0,
		context => q|label in the notify about version tag activity|
	},

	'who to notify' => {
		message => q|Notify whom?|,
		lastUpdated => 0,
		context => q|label in the notify about version tag activity|
	},

	'who to notify help' => {
		message => q|Notify the person that created the tag, the person that committed the tag, or the people who were allowed to work on the tag.|,
		lastUpdated => 0,
		context => q|hover help for the who to notify field|
	},

	'notify message' => {
		message => q|Notification Message|,
		lastUpdated => 0,
		context => q|label in the notify about version tag activity|
	},

	'notify message help' => {
		message => q|Type a message that will be sent along with the tag data.|,
		lastUpdated => 0,
		context => q|hover help for the notify message field|
	},

	'notify about version tag' => {
		message => q|Notify About Version Tag|,
		lastUpdated => 0,
		context => q|the name of the activity|
	},

	'approval message' => {
		message => q|Approval Message|,
		lastUpdated => 0,
		context => q|label in the request approval for version tag activity|
	},

	'approval message help' => {
		message => q|Type a message that will be sent to the approver's along with the approval link and the tag data.|,
		lastUpdated => 0,
		context => q|hover help for the approval message field|
	},

	'do on deny' => {
		message => q|Do On Deny|,
		lastUpdated => 0,
		context => q|label in the request approval for version tag activity|
	},

	'do on deny help' => {
		message => q|What workflow should we run if the tag is denied approval?|,
		lastUpdated => 0,
		context => q|hover help for the do on deny field|
	},

	'group to approve' => {
		message => q|Group To Approve|,
		lastUpdated => 0,
		context => q|label in the request approval for version tag activity|
	},

	'group to approve help' => {
		message => q|Which group should be notified and allowed to approve or deny this tag?|,
		lastUpdated => 0,
		context => q|hover help for the group to approve field|
	},

	'request approval for version tag' => {
		message => q|Request Approval For Version Tag|,
		lastUpdated => 0,
		context => q|the name of the activity|
	},

	'unlock version tag' => {
		message => q|Unlock Version Tag|,
		lastUpdated => 0,
		context => q|the name of the activity|
	},

	'current tag is called' => {
		message => q|You are currently working under a tag called|,
		lastUpdated => 0,
		context => q|manage version tags|
	},

	'created on' => {
		message => q|Created On|,
		lastUpdated => 0,
		context => q|manage version tags|
	},

	'created by' => {
		message => q|Created By|,
		lastUpdated => 0,
		context => q|manage version tags|
	},

	'committed on' => {
		message => q|Commited On|,
		lastUpdated => 0,
		context => q|manage committed versions|
	},

	'committed by' => {
		message => q|Committed By|,
		lastUpdated => 0,
		context => q|manage committed versions|
	},

	'group to use' => {
		message => q|Group To Use|,
		lastUpdated => 0,
		context => q|version tag editor|
	},

	'trash version tag' => {
		message => q|Trash Version Tag|,
		context => q|The name of the workflow activity.|,
		lastUpdated => 0,
	},

	'rollback version tag' => {
		message => q|Rollback Version Tag|,
		context => q|The name of the workflow activity.|,
		lastUpdated => 0,
	},

	'commit version tag' => {
		message => q|Commit Version Tag|,
		context => q|The name of the workflow activity.|,
		lastUpdated => 0,
	},

	'group to use help' => {
		message => q|Which group is allowed to use this tag?|,
		lastUpdated => 0,
		context => q|hover help for group to use field|
	},

	'rollback version tag confirm' => {
		message => q|Are you certain you wish to delete this version tag and all content created under it? It CANNOT be restored if you delete it.|,
		lastUpdated => 0,
		context => q|The prompt for purging a version tag from the asset tree.|
	},

	'commit version tag confirm' => {
		message => q|Are you certain you wish to commit this version tag and everything edited under it?|,
		lastUpdated => 0,
		context => q|The prompt for committing a version tag to the asset tree.|
	},

	'set tag' => {
		message => q|Set As Working Tag|,
		lastUpdated => 0,
		context => q|The label for choosing as a tag to work under.|
	},

	'revisions in tag' => {
		message => q|Revisions In Tag|,
		lastUpdated => 0,
		context => q|The label for displaying the revisions created under a specific tag.|
	},

	'commit' => {
		message => q|Commit|,
		lastUpdated => 0,
		context => q|The label for committing a tag to the asset tree.|
	},

	'rollback' => {
		message => q|Rollback|,
		lastUpdated => 0,
		context => q|The label for purging a revision from the asset tree.|
	},

	'manage versions' => {
		message => q|Manage versions.|,
		lastUpdated => 0,
		context => q|Menu item in version tag manager.|
	},

	'manage pending versions' => {
		message => q|Manage pending versions.|,
		lastUpdated => 0,
		context => q|Menu item in version tag manager.|
	},

	'manage committed versions' => {
		message => q|Manage committed versions.|,
		lastUpdated => 0,
		context => q|Menu item in version tag manager.|
	},

	'edit version tag' => {
		message => q|Edit Version Tag|,
		lastUpdated => 0,
		context => q|Admin console label.|
	},

	'version tag name' => {
		message => q|Version Tag Name|,
		lastUpdated => 1129403466,
		context => q|Admin console label.|
	},

	'version tag name description' => {
		message => q|<p>Enter a name to tag the work you will do on this version of the asset.  The tag will be used to reference this work when it is time to commit, rollback or make further edits.</p>|,
		lastUpdated => 1129403469,
	},

	'version tag name description commit' => {
		message => q|<p>The name of the version tag you are about to commit.</p>|,
		lastUpdated => 1129403469,
	},

	'content versioning' => {
		message => q|Content Versioning|,
		lastUpdated => 0,
		context => q|Admin console label.|
	},

	'committed versions' => {
		message => q|Committed Versions|,
		lastUpdated => 0,
		context => q|Admin console label.|
	},

	'pending versions' => {
		message => q|Pending Versions|,
		lastUpdated => 0,
		context => q|Admin console label.|
	},

	'add a version tag' => {
		message => q|Add a version tag.|,
		lastUpdated => 0,
		context => q|Menu item in version tag manager.|
	},

	'purge revision prompt' => {
		message => q|Are you certain you wish to delete this revision of this asset? It CANNOT be restored if you delete it.|,
		lastUpdated => 1142455321,
		context => q|The prompt for purging a revision from the manage revisios screen.|
	},

	'manage version tags' => {
		message => q|Manage Version Tags|,
		lastUpdated => 1148359381,
	},

	'workflow' => {
		message => q|Workflow|,
		lastUpdated => 1148445024,
	},

	'workflow help' => {
		message => q|Choose a workflow to handle your version tag.|,
		lastUpdated => 1148445024,
	},

	'manage version tags body' => {
		message => q|<p>This screen lists all uncommitted version tags in WebGUI, their status and an interface to manage them.  If you are currently working under a tag, the name of the tag is prominently displayed for reference.</p>
<p>The icons next to each tag allow each tag to be edited, or deleted.  The name of the tag is a link to manage work done in the tag.  The date the tag was created and the username of the user who created are shown as well.  A link is provided so that the tag can be committed</p>
<p>Links are also provided to set any other version tag as your new current working version tag.  From that point forward, all work will be done under the new tag.</p>|,
		lastUpdated => 1165518479,
	},

	'manage pending versions body' => {
		message => q|<p>This screen presents a list of pending version tags by name.  Version tags are pending after they have been committed and before they have been approved and/or processed, or if they are in the process of becoming unlocked to be re-edited.  Each name is a link to display the list of revisions in this tag.</p>|,
		lastUpdated => 0,
	},

	'manage committed versions body' => {
		message => q|<p>This screen lists all committed version tags in WebGUI, information about the tags and an interface to manage them.</p>
<p>The name of the tag is a link to display what work was performed in the tag.  The date the tag was committed and the username of the user who committed the tag are shown as well.  A link is provided so that the tag can be rolled back.</p>
|,
		lastUpdated => 1148359381,
	},

	'commit version tag body' => {
		message => q|<p>Committing the version tag will make its content the current version of content that is used and displayed on your website.</p>
|,
		lastUpdated => 1148444236,
	},

	'edit version tag body' => {
		message => q|<p>In this screen you will create a new version tag for use on the site, or edit an existing version tag.  Members of the Manage Version Tag group will have the additionaly ability to define how the version tag is handled via a workflow and which group is allowed to make edits under the tag.</p>
|,
		lastUpdated => 1148444236,
	},

	'topicName' => {
		message => q|Version Control|,
		lastUpdated => 1148360141,
	},

};

1;
