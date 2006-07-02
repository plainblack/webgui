package WebGUI::Help::Workflow_Activity_TrashClipboard;

our $HELP = {
	'trash clipboard' => {
		title => 'activityName',
		body => 'trash clipboard body',
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
                                namespace => 'Workflow_Activity_TrashClipboard',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
