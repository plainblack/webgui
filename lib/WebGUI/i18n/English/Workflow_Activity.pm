package WebGUI::i18n::English::Workflow_Activity;

our $I18N = {
	'description help' => {
		message => q|Put a long explaination here of what this activity is doing.|,
		context => q|the hover help for the description field|,
		lastUpdated => 0,
	},

	'description' => {
		message => q|Description|,
		context => q|a label for the human readable description|,
		lastUpdated => 0,
	},

	'title help' => {
		message => q|Put a name here that identifies what this activity is doing.|,
		context => q|the hover help for the title field|,
		lastUpdated => 0,
	},

	'title' => {
		message => q|Title|,
		context => q|a label for the human readable title|,
		lastUpdated => 0,
	},

	'add/edit workflow activity' => {
		message => q|Add/Edit Workflow Activity|,
		context => q|Title for the add and edit workflow activity screen|,
		lastUpdated => 0,
	},

	'add/edit workflow activity body' => {
		message => q|Add/Edit Workflow Activity|,
		context => q|<p>Most Workflow Activities have these basic fields and properties:</p>|,
		lastUpdated => 0,
	},

	'list of installed activities' => {
		message => q|List of Installed Workflow Activities|,
		lastUpdated => 0,
	},

	'activities list body' => {
		message => q|<p>Making a Workflow Activity available for use on your site is a two step process.</p>
<div>
<ol>
<li>The activity must be put in the Activities directory in the WebGUI source code: lib/WebGUI/Workflow/Activities.</li>
<li>The activity must be enabled in your WebGUI.conf file, in the "workflowActivities" section.</li>
</ol>
</div>
<p>The table below shows which activities are installed on your site and which have been configured in your WebGUI.conf file.  It does not say if the activity is used in a Workflow.</p>
|,
		lastUpdated => 0,
	},

	'activity enabled header' => {
		message => q|Activity Enabled?|,
		lastUpdated => 1112591289,
		context => q|Table heading in List of Activities help page.  Short for "Is this Activity enabled?"|,
	},

	'activity name' => {
		message => q|Activity Name|,
		lastUpdated => 1112591289,
		context => q|Table heading in List of Activities help page.  Short for "Is this Activity enabled?"|,
	},

	'topicName' => {
		message => q|Workflow Activities|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

};

1;
