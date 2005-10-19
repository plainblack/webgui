package WebGUI::Help::Asset_EventsCalendar;

our $HELP = {
	'events calendar add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => '507',
                                description => '507 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '94',
                                description => '94 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '80',
                                description => '80 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '81',
                                description => '81 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '84',
                                description => '84 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '90',
                                description => '90 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '19',
                                description => '19 description',
                                namespace => 'Asset_EventsCalendar',
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'event add/edit',
				namespace => 'Asset_Event'
			},
			{
				tag => 'events calendar template',
				namespace => 'Asset_EventsCalendar'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},
	'events calendar template' => {
		title => '94',
		body => '95',
		fields => [
		],
		related => [
			{
				tag => 'events calendar add/edit',
				namespace => 'Asset_EventsCalendar'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},
};

1;
