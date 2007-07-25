package WebGUI::i18n::English::Workflow_Activity_SyncProfilesToLdap;

our $I18N = {
	'activityName' => {
		message => q|Sync Profiles To LDAP|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'sync profiles to ldap body' => {
		message => q|<p>This workflow activity will synchronize the profiles of all users configured for LDAP authentication.  Note that this only comes from LDAP and goes to WebGUI and not the other direction.</p>|,
		lastUpdated => 0,
	},

};

1;
