package WebGUI::Help::Workflow_Activity_PurgeOldAssetRevisions;

our $HELP = {
	'purge old asset revisions' => {
		title => 'topicName',
		body => 'purge old asset revisions body',
		isa => [
			{
				namespace => "Workflow_Activity",
				tag => "add/edit workflow activity"
			},
		],
		fields => [
                        {
                                title => 'purge revision after',
                                description => 'purge revision after help',
                                namespace => 'Asset',
                        },
		],
		variables => [
		],
		related => [
		],
	},

};

1;  ##All perl modules must return true
