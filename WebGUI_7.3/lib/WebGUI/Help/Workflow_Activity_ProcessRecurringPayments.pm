package WebGUI::Help::Workflow_Activity_ProcessRecurringPayments;

our $HELP = {
	'process recurring payments' => {
		title => 'activityName',
		body => 'process recurring payments body',
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
			{
				tag => 'settings',
				namespace => 'WebGUI'
			}
		],
	},

};

1;  ##All perl modules must return true
