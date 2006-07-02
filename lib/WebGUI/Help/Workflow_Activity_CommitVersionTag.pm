package WebGUI::Help::Workflow_Activity_CommitVersionTag;

our $HELP = {
	'commit version tag' => {
		title => 'activityName',
		body => 'commit version tag body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
