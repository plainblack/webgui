package WebGUI::Help::Workflow_Activity_NotifyAboutVersionTag;

our $HELP = {
	'notify about version tag' => {
		title => 'topicName',
		body => 'notify about version tag body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'who to notify',
                                description => 'who to notify help',
                                namespace => 'VersionTag',
                        },
                        {
                                title => 'notify message',
                                description => 'notify message help',
                                namespace => 'VersionTag',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
