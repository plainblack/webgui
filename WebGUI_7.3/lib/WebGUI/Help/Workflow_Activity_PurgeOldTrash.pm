package WebGUI::Help::Workflow_Activity_PurgeOldTrash;

our $HELP = {
	'purge old trash' => {
		title => 'activityName',
		body => 'purge old trash body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'purge trash after',
                                description => 'purge trash after help',
                                namespace => 'Asset',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
