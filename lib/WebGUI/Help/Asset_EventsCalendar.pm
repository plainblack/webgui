package WebGUI::Help::Asset_EventsCalendar;

our $HELP = {
	'events calendar add/edit' => {
		title => '61',
		body => '71',
		fields => [
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
