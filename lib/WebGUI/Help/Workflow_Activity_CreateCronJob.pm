package WebGUI::Help::Workflow_Activity_CreateCronJob;

our $HELP = {
	'create cron job' => {
		title => 'topicName',
		body => 'create cron job body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'is enabled',
                                description => 'is enabled help',
                                namespace => 'Workflow_Cron',
                        },
                        {
                                title => 'run once',
                                description => 'run once help',
                                namespace => 'Workflow_Cron',
                        },
                        {
                                title => 'workflow',
                                description => 'workflow help',
                                namespace => 'Workflow_Cron',
                        },
                        {
                                title => 'priority',
                                description => 'priority help',
                                namespace => 'Workflow_Cron',
                        },
                        {
                                title => 'minute of hour',
                                description => 'minute of hour help',
                                namespace => 'Workflow_Cron',
                        },
                        {
                                title => 'hour of day',
                                description => 'hour of day help',
                                namespace => 'Workflow_Cron',
                        },
                        {
                                title => 'day of month',
                                description => 'day of month help',
                                namespace => 'Workflow_Cron',
                        },
                        {
                                title => 'month of year',
                                description => 'month of year help',
                                namespace => 'Workflow_Cron',
                        },
                        {
                                title => 'day of week',
                                description => 'day of week help',
                                namespace => 'Workflow_Cron',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
