package WebGUI::Help::EventsCalendar;

our $HELP = {
	'events calendar add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'event add/edit',
				namespace => 'EventsCalendar'
			},
			{
				tag => 'events calendar template',
				namespace => 'EventsCalendar'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},
	'event add/edit' => {
		title => '72',
		body => '73',
		related => [
			{
				tag => 'event template',
				namespace => 'EventsCalendar'
			},
			{
				tag => 'events calendar add/edit',
				namespace => 'EventsCalendar'
			}
		]
	},
	'events calendar template' => {
		title => '94',
		body => '95',
		related => [
			{
				tag => 'events calendar add/edit',
				namespace => 'EventsCalendar'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
	'event template' => {
		title => '96',
		body => '97',
		related => [
			{
				tag => 'event add/edit',
				namespace => 'EventsCalendar'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
