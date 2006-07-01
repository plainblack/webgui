package WebGUI::Help::Workflow;

our $HELP = {
	'manage workflows' => {
		title => 'manage workflows',
		body => 'manage workflow help body',
		fields => [
		],
		related => [
			{
				tag => 'show running workflows',
				namespace => 'Workflow'
			},
		],
	},

	'show running workflows' => {
		title => 'show running workflows',
		body => 'show running workflows body',
		fields => [
		],
		related => [
			{
				tag => 'manage workflows',
				namespace => 'Workflow'
			},
		],
	},

};

1;  ##All perl modules must return true
