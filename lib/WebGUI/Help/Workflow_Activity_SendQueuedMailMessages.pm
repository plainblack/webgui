package WebGUI::Help::Workflow_Activity_SendQueuedMailMessages;

our $HELP = {
	'get cs post' => {
		title => 'topicName',
		body => 'send queued mail messages body',
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
