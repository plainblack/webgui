package WebGUI::Help::Workflow_Activity_DecayKarma;

our $HELP = {
	'decay karma' => {
		title => 'activityName',
		body => 'decay karma body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'minimum karma',
                                description => 'minimum karma help',
                                namespace => 'Workflow_Activity_DecayKarma',
                        },
                        {
                                title => 'decay factor',
                                description => 'decay factor help',
                                namespace => 'Workflow_Activity_DecayKarma',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
