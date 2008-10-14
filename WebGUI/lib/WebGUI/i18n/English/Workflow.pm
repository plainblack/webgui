package WebGUI::i18n::English::Workflow;
use strict;

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

    'mode' => {
        message => q|Mode|,
    },

	'mode help' => {
		message => q|The mode of a workflow determines when and how a workflow is run.
        <p><b>Parallel</b> workflows run as many instances of the workflow as there are in existence.</p>
        <p><b>Singleton</b> workflows run exactly one instance of a given type at any one time, and if a
        new workflow of that type is created while the original is running, it will be discarded.</p>
        <p><b>Serial</b> workflows run one workflow instance of a given type at a time, in the order it was
        created.</p> |,
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

	'edit priority success' => {
		message => q|Workflow priority updated successfully.|,
		context => q||,
		lastUpdated => 0,
	},

	'edit priority instance not found error' => {
		message => q|I could not find that workflow. Perhaps it's finished running.|,
		context => q||,
		lastUpdated => 0,
	},

	'edit priority cancel' => {
		message => q|cancel|,
		context => q||,
		lastUpdated => 0,
	},

	'edit priority update priority' => {
		message => q|Update Priority|,
		context => q||,
		lastUpdated => 0,
	},

	'spectre not running error' => {
		message => q|Spectre <b>is not running</b>.<br />Unable to get detailed workflow information.<br />|,
		context => q||,
		lastUpdated => 1192031332,
	},

	'spectre no info error' => {
		message => q|Spectre <b>is running</b>, but I was not able to get detailed workflow information.<br />|,
		context => q||,
		lastUpdated => 0,
	},

	'workflow type count' => {
		message => q|<h2>%d %s Workflows</h2>|,
		context => q||,
		lastUpdated => 0,
	},

	'title header' => {
		message => q|Title|,
		context => q||,
		lastUpdated => 0,
	},

	'priority header' => {
		message => q|Current/Original Priority|,
		context => q||,
		lastUpdated => 0,
	},

	'activity header' => {
		message => q|Current Activity|,
		context => q||,
		lastUpdated => 0,
	},

	'last state header' => {
		message => q|Last State|,
		context => q||,
		lastUpdated => 0,
	},

	'last run time header' => {
		message => q|Last Run Time|,
		context => q||,
		lastUpdated => 0,
	},

	'edit priority setting error' => {
		message => q|There was an error setting the new priority.|,
		context => q||,
		lastUpdated => 0,
	},

	'edit priority no spectre error' => {
		message => q|Spectre <b>is not running</b>.<br/>Unable to get workflow information.|,
		context => q||,
		lastUpdated => 0,
	},

	'edit priority bad request' => {
		message => q|You have made a bad request.|,
		context => q||,
		lastUpdated => 0,
	},

	'edit priority no info error' => {
		message => q|Spectre <b>is running</b>, but I was not able to update the priority.|,
		context => q||,
		lastUpdated => 0,
	},

	'edit priority unknown error' => {
		message => q|There was an unknown error updating the workflow priority. Please try again later.|,
		context => q||,
		lastUpdated => 0,
	},

        'form control none label' => {
            message     => q{None},
            context     => q{Default label to select "None" for a workflow},
            lastUpdated => 0,
        },

	'topicName' => {
		message => q|Workflow|,
		context => q|The title of the workflow interface.|,
		lastUpdated => 0,
	},

};

1;
