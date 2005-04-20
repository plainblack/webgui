package WebGUI::Help::Asset_Event;

our $HELP = {
	'event add/edit' => {
		title => '72',
		body => '73',
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
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},
};

1;
