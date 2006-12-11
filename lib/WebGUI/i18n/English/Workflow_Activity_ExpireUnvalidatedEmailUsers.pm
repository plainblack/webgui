package WebGUI::i18n::English::Workflow_Activity_ExpireUnvalidatedEmailUsers;

our $I18N = {
	'activityName' => {
		message => q|Expire Unvalidated Email Users|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 1165406607,
	},

	'interval hoverHelp' => {
		message => q|How long a user must remain with their email address unvalidated before they are deleted.|,
		lastUpdated => 1165406607,
	},

	'interval label' => {
		message => q|Expiry Time|,
		lastUpdated => 1165406607,
	},

	'expire unvalidated email users' => {
		message => q|<p>This workflow activity will go through all users who requested new accounts but who never validated their email addresses and expire their accounts.  The expiration date is configurable.</p>
<p>
|,
		lastUpdated => 0,
	},
};

1;
