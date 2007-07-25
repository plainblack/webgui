package WebGUI::Help::Workflow_Activity_TrashExpiredEvents;

our $HELP = {
	'trash expired events' => {
		title => 'activityName',
		body => 'trash expired events body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'trash after',
                                description => 'trash after help',
                                namespace => 'Workflow_Activity_TrashExpiredEvents',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
