package WebGUI::i18n::English::Workflow_Activity_ExpireSubscriptionCodes;

our $I18N = {
	'activityName' => {
		message => q|Expire Subscription Codes|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'expire subscription codes body' => {
		message => q|<p>This workflow activity will go through all subscription codes and expire any subscription code whose status is unused after the expiration date for the subscription code has passed.  The expiration date is calculated from the date it was created and interval it was set to expire.</p>|,
		lastUpdated => 0,
	},

};

1;
