package WebGUI::Help::Workflow_Activity_CleanTempStorage;

our $HELP = {
	'clean temp storage' => {
		title => 'activityName',
		body => 'clean temp storage body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'storage timeout',
                                description => 'storage timeout help',
                                namespace => 'Workflow_Activity_CleanTempStorage',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
