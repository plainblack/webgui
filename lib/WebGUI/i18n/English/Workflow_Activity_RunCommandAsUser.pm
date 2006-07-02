package WebGUI::i18n::English::Workflow_Activity_RunCommandAsUser;

our $I18N = {
	'command help' => {
		message => q|Type the command you wish to run here. Feel free to use macros for additional parameters.|,
		context => q|the hover help for the command field|,
		lastUpdated => 0,
	},

	'command' => {
		message => q|Command|,
		context => q|a label for the command to be run|,
		lastUpdated => 0,
	},

	'activityName' => {
		message => q|Run Command As User|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'run command as user body' => {
		message => q|<p>This workflow activity will switch the session's current user to that passed in to the Activity.  Then it will process any macros found in the command and execute the command on the command line.</p>|,
		lastUpdated => 0,
	},

};

1;
