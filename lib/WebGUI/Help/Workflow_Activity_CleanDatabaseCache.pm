package WebGUI::Help::Workflow_Activity_CleanDatabaseCache;

our $HELP = {
	'clean database cache' => {
		title => 'topicName',
		body => 'clean database cache body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'size limit',
                                description => 'size limit help',
                                namespace => 'Workflow_Activity_CleanDatabaseCache',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
