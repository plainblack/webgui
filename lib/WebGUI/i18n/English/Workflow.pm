package WebGUI::i18n::English::Workflow;

our $I18N = { 
	'no object' => {
		message => q|No Object|,
		context => q|used when selecting an object type to be passed through a workflow|,
		lastUpdated => 0,
	},

	'confirm delete activity' => {
		message => q|Are you certain you wish to delete this activity from this workflow?|,
		context => q|prompt the user before deleting an activity from a workflow|,
		lastUpdated => 0,
	},

	'are you sure you want to delete this workflow' => {
		message => q|Are you certain you wish to delete this workflow and all running instances of it?|,
		context => q|prompt the user before deleting a workflow|,
		lastUpdated => 0,
	},

	'object type help' => {
		message => q|What type of objects do you want this workflow to be able to handle?|,
		context => q|the hover help for the object type field|,
		lastUpdated => 0,
	},

	'object type' => {
		message => q|Object Type|,
		context => q|a label for the form that lets users choose what kind of objects a workflow can handle|,
		lastUpdated => 0,
	},

	'is singleton help' => {
		message => q|If yes is selected then only one instance of this workflow will be allowed to be created at one time. Generally speaking this would be a bad idea for approval workflows, but is probably a good idea for workflows that download emails from a remote server, to avoid getting duplicates.|,
		context => q|the hover help for the is singleton field|,
		lastUpdated => 0,
	},

	'is singleton' => {
		message => q|Is a singleton?|,
		context => q|A question that asks the user whether this workflow may be instanciated multiple times concurrently or not.|,
		lastUpdated => 0,
	},

	'is serial help' => {
		message => q|If yes is selected then only one instance of this workflow will be allowed to be run at one time, while new instances get queued up and wait for the running one to complete. This is generally bad for a workflow, but it can be good when multiple instances of workflow have to operate on the same data.|,
		context => q|the hover help for the is serial field|,
		lastUpdated => 0,
	},

	'is serial' => {
		message => q|Is serial?|,
		context => q|A question that asks the user whether this workflow may be instanciated multiple times concurrently or not.|,
		lastUpdated => 0,
	},

	'description help' => {
		message => q|Fill out a detailed description of what this workflow does and is used for for future reference.|,
		context => q|the hover help for the description field|,
		lastUpdated => 0,
	},

	'description' => {
		message => q|Description|,
		context => q|A more detailed description of what this workflow does.|,
		lastUpdated => 0,
	},

	'is enabled help' => {
		message => q|If this is set to yes, then the system will be allowed to create running instances of this workflow.|,
		context => q|the hover help for the enabled field|,
		lastUpdated => 0,
	},

	'is enabled' => {
		message => q|Is Enabled?|,
		context => q|Yes or no question asking the user if this workflow is enabled.|,
		lastUpdated => 0,
	},

	'title help' => {
		message => q|A human readable label to easily identify what this workflow does.|,
		context => q|the hover help for the title field|,
		lastUpdated => 0,
	},

	'title' => {
		message => q|Title|,
		context => q|A human readable label to identify a workflow.|,
		lastUpdated => 0,
	},

	'enabled' => {
		message => q|Enabled|,
		context => q|A label to indicate that the workflow is ready to run.|,
		lastUpdated => 0,
	},

	'disabled' => {
		message => q|Disabled|,
		context => q|A label to indicate that the workflow is not ready to run.|,
		lastUpdated => 0,
	},

	'workflowId' => {
		message => q|Workflow ID|,
		context => q|a label for the unique id representing the workflow|,
		lastUpdated => 0,
	},

	'manage workflows' => {
		message => q|Manage all workflows.|,
		context => q|clicking on this text linked will show the user a list of all workflows|,
		lastUpdated => 0,
	},

	'add a new workflow' => {
		message => q|Add a new workflow.|,
		context => q|clicking on this text linked will add a new workflow|,
		lastUpdated => 0,
	},

	'topicName' => {
		message => q|Workflow|,
		context => q|The title of the workflow interface.|,
		lastUpdated => 0,
	},

};

1;
