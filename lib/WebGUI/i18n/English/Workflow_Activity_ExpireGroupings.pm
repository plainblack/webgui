package WebGUI::i18n::English::Workflow_Activity_ExpireGroupings;

our $I18N = {
	'activityName' => {
		message => q|Expire Groupings|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'expire groupings body' => {
		message => q|<p>This workflow activity will go through all Groups and handle changes in group membership.  If expiration notification has been setup for the group, users will be notified at the appropriate time before their membership expires.  After the delete offset has passed from their expiration date, the user is deleted from the group.</p>
|,
		lastUpdated => 0,
	},

};

1;
