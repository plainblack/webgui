package WebGUI::Help::Workflow_Activity_NotifyAdminsWithOpenVersionTags;

our $HELP = {
	'notify admins with open version tags' => {
		title => 'activityName',
		body => 'notify admins with open version tags body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
            {
                title => 'days left open label',
                description => 'days left open hoverhelp',
                namespace => 'Workflow_Activity_NotifyAdminsWithOpenVersionTags',
            },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
