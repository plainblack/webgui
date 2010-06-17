package WebGUI::i18n::English::VersionTag;
use strict;

our $I18N = {
	'export version tag to html' => {
		message => q|Export Version Tag To HTML|,
		context => q|the title of the workflow activity of the same name|,
		lastUpdated => 0 
	},

	'back to site' => {
		message => q|Back to site.|,
		lastUpdated => 0 
	},

	'leave this tag' => {
		message => q|Leave This Tag|,
		lastUpdated => 0 
	},

	'bad commit' => {
		message => q|Something bad happened while trying to commit your content. Please contact your system
        administrator.|,
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

	'workflow' => {
		message => q|Workflow|,
		lastUpdated => 1148445024,
	},

	'workflow help' => {
		message => q|Choose a workflow to handle your version tag.|,
		lastUpdated => 1148445024,
	},

	'commit version tag' => {
		message => q|Commit Version Tag|,
		context => q|The name of the workflow activity.|,
		lastUpdated => 0,
	},


    'manageRevisionsInTag moveTo new' => {
        message     => q{-> New Version Tag},
        lastUpdated => 0,
        context     => q{Option to move revisions to a new version tag},
    },

    'manageRevisionsInTag with selected' => {
        message     => q{With Selected: },
        lastUpdated => 0,
        context     => q{Lead-in for actions to perform after selecting revisions},
    },

    'manageRevisionsInTag purge' => {
        message     => q{Purge},
        lastUpdated => 0,
        context     => q{Label for button to purge revisions},
    },

    'manageRevisionsInTag move' => {
        message     => q{Move To:},
        lastUpdated => 0,
        context     => q{Label for button to move revisions},
    },
    
    'manageRevisionsInTag update' => {
        message     => q{Update Version Tag},
        lastUpdated => 0,
        context     => q{Label for button to update revisions},
    },

    'continue with workflow' => {
        message     => q{-- Continue with this workflow},
        lastUpdated => 0,
        context     => q{Label to disable branching in workflow},
    },

    'do on approve' => {
        message     => q{Do On Approve},
        lastUpdated => 0,
        context     => q{Label for activity property},
    },

    'do on approve help' => {
        message     => q{The workflow to perform when the version tag is approved by this activity.},
        lastUpdated => 0,
        context     => q{Help for activity property},
    },
    
	'topicName' => {
		message => q|Version Control|,
		lastUpdated => 1148360141,
	},
    
    'wait until' => {
        message     => q|Wait Until|,
        lastUpdated => 1148360141,
    },
    
    'wait until label' => {
        message     => q|Wait Until|,
        lastUpdated => 1148360141,
    },
    
    'wait until hoverhelp' => {
        message     => q|Choose the version tag field to use for determining how long to wait before continuing on with this workflow.  Choosing Start Time will indicate that you would like to wait until the Start Time of the version tag to continue on with the workflow. Choosing End Time will indicate that you wish to wait until the End Time of the version tag to conitinue.|,
        lastUpdated => 1148360141,
    },
    
    'version start time' => {
        message     => q|Version Start Time|,
        lastUpdated => 1148360141,
    },
    
    'version end time' => {
        message     => q|Version End Time|,
        lastUpdated => 1148360141,
    },
    
    'startTime label' => {
        message     => q|Start Time|,
        lastUpdated => 1148360141,      
    },
    
    'startTime hoverHelp' => {
        message    => q|Enter the time you would like this version tag to show up on your website.  Please note you must have workflow configured properly for this to work correctly|,
        lastUpdate => 1148360141,
    },
    
    'endTime hoverHelp' => {
        message    => q|Enter the time you would like this version tag to stop showing up on your website.  Please note you must have workflow configured properly for this to work correctly|,
        lastUpdate => 1148360141,
    },
    
    'endTime label' => {
        message     => q|End Time|,
        lastUpdated => 1148360141,      
    },
    
    'approved'  => {
        message     => q{approved},
        lastUpdated => 0,
        context     => 'Status of version tag',
    },

    'denied' => {
        message     => q{denied},
        lastUpdated => 0,
        context     => 'Status of version tag',
    },

    'approveVersionTag message' => {
        message     => q{Your version tag has been %s. <a href="%s">Back to site</a>.},
        lastUpdated => 0,
        context     => q{Message for when someone approves a version tag},
    },
    
    "error permission www_manageRevisionsInTag title" => {
        message     => q{Permission Denied},
        lastUpdated => 0,
        context     => q{Title of "permission denied" page for Manage Revisions In Tag},
    },

    "error permission www_manageRevisionsInTag body" => {
        message     => q{You are not allowed to view this version tag. It is possible that it has already been approved or denied. },
        lastUpdated => 0,
        context     => q{Explanation of Permission Denied message},
    },

    "Rolling back %s" => {
        message     => q{Rolling back %s},
        lastUpdated => 0,
        context     => q{},
    },

};

1;
