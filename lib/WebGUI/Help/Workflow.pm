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

	'add a new workflow' => {
		title => 'add a new workflow',
		body => 'add a new workflow body',
		fields => [
                        {
                                title => 'object type',
                                description => 'object type help',
                                namespace => 'Workflow',
			},
		],
		related => [
			{
				tag => 'manage workflows',
				namespace => 'Workflow'
			},
			{
				tag => 'edit workflow',
				namespace => 'Workflow'
			},
		],
	},

	'edit workflow' => {
		title => 'edit workflow',
		body => 'edit workflow body',
		fields => [
                        {
                                title => 'object type',
                                description => 'object type help2',
                                namespace => 'Workflow',
			},
                        {
                                title => 'title',
                                description => 'title help',
                                namespace => 'Workflow',
			},
                        {
                                title => 'description',
                                description => 'description help',
                                namespace => 'Workflow',
			},
                        {
                                title => 'is enabled',
                                description => 'is enabled help',
                                namespace => 'Workflow',
			},
                        {
                                title => 'mode',
                                description => 'mode help',
                                namespace => 'Workflow',
			},
		],
		related => [
			{
				tag => 'manage workflows',
				namespace => 'Workflow'
			},
			{
				tag => 'add a new workflow',
				namespace => 'Workflow'
			},
		],
	},

};

1;  ##All perl modules must return true
