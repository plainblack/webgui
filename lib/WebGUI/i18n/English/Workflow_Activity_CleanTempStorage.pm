package WebGUI::i18n::English::Workflow_Activity_CleanTempStorage;

our $I18N = {
	'storage timeout help' => {
		message => q|How old should temp files be before we delete them?|,
		context => q|the hover help for the storage timeout field|,
		lastUpdated => 0,
	},

	'storage timeout' => {
		message => q|Storage Timeout|,
		context => q|a label indicating how old temp files should be before we delete them|,
		lastUpdated => 0,
	},

	'topicName' => {
		message => q|Clean Temp Storage|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'clean temp storage body' => {
		message => q|<p>This workflow activity goes through the temporary area of the uploads directory for this site and deletes any files that are older than the user configured timeout.</p>|,
		lastUpdated => 0,
	},

};

1;
