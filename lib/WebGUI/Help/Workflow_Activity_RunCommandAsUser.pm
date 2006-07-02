package WebGUI::Help::Workflow_Activity_RunCommandAsUser;

our $HELP = {
	'run command as user' => {
		title => 'activityName',
		body => 'run command as user body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'command',
                                description => 'command help',
                                namespace => 'Workflow_Activity_RunCommandAsUser',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
