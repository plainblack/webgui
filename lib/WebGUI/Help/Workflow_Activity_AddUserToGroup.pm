package WebGUI::Help::Workflow_Activity_AddUserToGroup;

our $HELP = {
	'add user to group' => {
		title => 'activityName',
		body => 'add user to group body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'group',
                                description => 'group help',
                                namespace => 'Workflow_Activity_AddUserToGroup',
                        },
                        {
                                title => 'expire offset',
                                description => 'expire offset help',
                                namespace => 'Workflow_Activity_AddUserToGroup',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
