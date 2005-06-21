package WebGUI::Help::Asset_Event;

our $HELP = {
	'event add/edit' => {
		title => '72',
		body => '73',
		fields => [
                        {
                                title => '512',
                                description => 'Description description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '513',
                                description => 'Start Date description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '514',
                                description => 'End Date description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '515',
                                description => '515 description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '530',
                                description => '530 description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '8',
                                description => 'Recurs every description',
                                namespace => 'Asset_Event',
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
