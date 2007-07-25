package WebGUI::Help::Workflow_Activity_NotifyAboutUser;

our $HELP = {
	'notify about user' => {
		title => 'activityName',
		body => 'notify about user body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'to',
                                description => 'to help',
                                namespace => 'Workflow_Activity_NotifyAboutUser',
                        },
                        {
                                title => 'subject',
                                description => 'subject help',
                                namespace => 'Workflow_Activity_NotifyAboutUser',
                        },
                        {
                                title => 'message',
                                description => 'message help',
                                namespace => 'Workflow_Activity_NotifyAboutUser',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
