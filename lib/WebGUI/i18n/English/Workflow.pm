package WebGUI::i18n::English::Workflow;

our $I18N = { 
	'run' => {
		message => q|Run|,
		context => q|Execute a workflow.|,
		lastUpdated => 0,
	},

	'show running workflows' => {
		message => q|Show running workflows.|,
		context => q|A label used to get to a display of running workflows.|,
		lastUpdated => 0,
	},

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
		context => q|the hover help for the object type field in the add workflow screen|,
		lastUpdated => 0,
	},

	'object type help2' => {
		message => q|The type of workflow that you selected to add.|,
		context => q|the hover help for the object type field in the edit workflow screen|,
		lastUpdated => 0,
	},

	'object type' => {
		message => q|Object Type|,
		context => q|a label for the form that lets users choose what kind of objects a workflow can handle|,
		lastUpdated => 0,
	},

    'singleton' => {
        message => q|Singleton|,
    },

    'serial' => {
        message => q|Serial|,
    },

    'parallel' => {
        message => q|Parallel|,
    },

    'realtime' => {
        message => q|Realtime|,
    },

    'mode' => {
        message => q|Mode|,
    },

	'mode help' => {
		message => q|The mode of a workflow determines the precidence of when and how a workflow is run.
        <p><b>Parallel</b> workflows asynchronously run as many instances of the workflow as there are in existence.</p>
        <p><b>Singleton</b> workflows asynchronously run exactly one instance of a given type at any one time, and if a
        new workflow of that type is created while the original is running, it will be discarded.</p>
        <p><b>Serial</b> workflows asynchronously run one workflow instance of a given type at a time, in the order it was
        created.</p>
        <p><b>Realtime</b> workflows synchronously (immediately) run all activities associated with it, because of this
        not all triggers support realtime workflows, and you can't use any asynchronous workflow activities (like
        version tag approval) in realtime workflows.</p>|,
		context => q|the hover help for the mode field|,
		lastUpdated => 0,
	},

	'description help' => {
		message => q|Fill out a detailed description of what this workflow does and what it is used for for future reference.|,
		context => q|the hover help for the description field|,
		lastUpdated => 1165513695,
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

	'edit workflow' => {
		message => q|Edit workflow|,
		lastUpdated => 0,
	},

	'manage workflow help body' => {
		message => q|
<p>This is the master screen for managing workflows.  All configured workflows are shown in a table by the title of the workflow, along with icons to edit or delete the workflow and the workflow's status, enabled or disabled. Links are provided to add new workflows and to show which, if any, workflows are presently running.</p>
<p>The Manage Workflow screen is accessed from the Admin Console.</p>
|,
		lastUpdated => 1151719637,
	},

	'show running workflows body' => {
		message => q|
<p>This screen can help you debug problems with workflows by showing which workflows are currently running.  The workflows are shown in a table with the name of the workflow, the date it started running.  If the workflow has a defined status, then that status will also be shown, along with the date the workflow's status was last updated.</p>
<p>The screen will not automatically update.  To update the list of running workflows, reload the page.</p>
|,
		lastUpdated => 1151719633,
	},

	'add a new workflow body' => {
		message => q|
<p>Adding a workflow is a two-step process:</p>
<div>
<ol>
<li>Select the type of workflow to add in this screen.</li>
<li>Edit the workflow and add activities to it in the screen that follows.</li>
</ol>
</div>
<p>Workflow types, and the kinds of activities that can be added to each, are configured in your WebGUI.conf file.</p>
|,
		lastUpdated => 1151719633,
	},

	'edit workflow body' => {
		message => q|
<p>Now that you have selected which type of workflow you want to add, you will edit the workflow
and add activities to it.</p>
<p>Below the fields in two columns are the set of activities that are available to be added, and activities, if any, that have already been added to the worflow.</p>
<p>To add a new activity to the workflow, click on its name.  This will take you to the screen to configure that activity for this workflow.</p>
<p>Activities that have already been added and configured are displayed by name in the order they will be executed by Spectre.  Icons next to the name of the activity allow it to be reordered, edited, deleted from this workflow.</p>
|,
		lastUpdated => 1151721687,
	},

	'topicName' => {
		message => q|Workflow|,
		context => q|The title of the workflow interface.|,
		lastUpdated => 0,
	},

};

1;
