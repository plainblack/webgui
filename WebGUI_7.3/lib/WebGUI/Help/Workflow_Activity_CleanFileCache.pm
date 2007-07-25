package WebGUI::Help::Workflow_Activity_CleanFileCache;

our $HELP = {
	'clean file cache' => {
		title => 'activityName',
		body => 'clean file cache body',
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
                                namespace => 'Workflow_Activity_CleanFileCache',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
