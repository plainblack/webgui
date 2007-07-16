package WebGUI::Help::Workflow_Activity;

our $HELP = {
	'add/edit workflow activity' => {
		title => 'add/edit workflow activity',
		body => 'add/edit workflow activity body',
		isa => [
		],
		fields => [
                        {
                                title => 'title',
                                description => 'title help',
                                namespace => 'Workflow_Activity',
                        },
                        {
                                title => 'description',
                                description => 'description help',
                                namespace => 'Workflow_Activity',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
