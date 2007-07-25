package WebGUI::Help::Workflow_Activity_RequestApprovalForVersionTag;

our $HELP = {
	'request approval for version tag' => {
		title => 'activityName',
		body => 'request approval for version tag body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'group to approve',
                                description => 'group to approve help',
                                namespace => 'VersionTag',
                        },
                        {
                                title => 'approval message',
                                description => 'approval message help',
                                namespace => 'VersionTag',
                        },
                        {
                                title => 'do on deny',
                                description => 'do on deny help',
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
