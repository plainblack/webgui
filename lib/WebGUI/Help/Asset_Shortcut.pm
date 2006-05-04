package WebGUI::Help::Asset_Shortcut;

our $HELP = {
	'shortcut add/edit' => {
		title => '5',
		body => '6',
		fields => [
			{
				title => '1',
				description => '1 description',
				namespace => 'Asset_Shortcut',
			},
			{
				title => 'shortcut template title',
				description => 'shortcut template title description',
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
				tag => 'field add/edit',
				namespace => 'Asset_Shortcut'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'metadata manage',
				namespace => 'Asset'
			},
			{
				tag => 'dashboard add/edit',
				namespace => 'Asset_Dashboard'
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
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'shortcut add/edit',
				namespace => 'Asset_Shortcut'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},
	'field add/edit' => {
		title => 'field add/edit title',
		body => 'field add/edit body',
		fields => [
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},

		]
	},
};

1;
