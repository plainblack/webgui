package WebGUI::Help::Workflow_Activity_TrashExpiredEvents;

our $HELP = {
	'trash expired events' => {
		title => 'topicName',
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
                                namespace => 'Asset_Event',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
