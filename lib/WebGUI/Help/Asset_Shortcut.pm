package WebGUI::Help::Asset_Shortcut;

our $HELP = {
	'shortcut add/edit' => {
		title => '5',
		body => '6',
		fields => [
			{
				title => '85',
				description => '85 description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => 'shortcut template title',
				description => 'shortcut template title description',
				namespace => 'Asset_Shortcut',
			},
#			{
#				title => 'override asset template',
#				description => 'override asset template description',
#				namespace => 'Asset_Shortcut',
#			},
			{
				title => '10',
				description => '10 description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => '7',
				description => '7 description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => '8',
				description => '8 description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => '9',
				description => '9 description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => '1',
				description => '1 description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => 'Shortcut by alternate criteria',
				description => 'Shortcut by alternate criteria description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => 'disable content lock',
				description => 'disable content lock description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => 'Resolve Multiples',
				description => 'Resolve Multiples description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => 'Criteria',
				description => 'Criteria description',
				namespace => 'Asset_Shortcut',
			},
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'metadata manage',
				namespace => 'Asset'
			},

		]
	},

	'shortcut template' => {
		title => 'shortcut template title',
		body => 'shortcut template body',
		fields => [
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},

		]
	},

	'field add/edit' => {
		title => 'shortcut template title',
		body => 'shortcut template body',
		fields => [
		],
		related => [
			{
				tag => 'wobjects using',
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
