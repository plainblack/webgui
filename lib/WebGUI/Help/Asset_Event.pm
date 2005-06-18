package WebGUI::Help::Asset_Event;

our $HELP = {
	'event add/edit' => {
		title => '72',
		body => '73',
		fields => [
                        {
                                title => '512',
                                description => 'Description description'
                        },
                        {
                                title => '513',
                                description => 'Start Date description'
                        },
                        {
                                title => '514',
                                description => 'End Date description'
                        },
                        {
                                title => '515',
                                description => '515 description'
                        },
                        {
                                title => '530',
                                description => '530 description'
                        },
                        {
                                title => '8',
                                description => 'Recurs every description'
                        },
                ],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'event template',
				namespace => 'Asset_Event'
			},
		]
	},
	'event template' => {
		title => '96',
		body => '97',
		fields => [
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},
};

1;
