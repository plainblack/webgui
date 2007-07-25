package WebGUI::Help::Workflow_Activity_CleanLoginHistory;

our $HELP = {
	'clean login history' => {
		title => 'activityName',
		body => 'clean login history body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'age to delete',
                                description => 'age to delete help',
                                namespace => 'Workflow_Activity_CleanLoginHistory',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
