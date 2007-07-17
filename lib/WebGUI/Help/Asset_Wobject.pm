package WebGUI::Help::Asset_Wobject;

our $HELP = {

	'wobjects using' => {
		title => '671',
		body => '626',
		fields => [
		],
		related => [
			{
				tag => 'style sheets using',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'wobject delete',
				namespace => 'Asset_Wobject'
			}
		]
	},

	'wobject add/edit' => {
		title => '677',
		body => '632',
		isa => 	[
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		],
		fields => [
                        {
                                title => '174',
                                description => '174 description',
                                namespace => 'Asset_Wobject',
				uiLevel => 5,
                        },
                        {
                                title => '1073',
                                description => '1073 description',
                                namespace => 'Asset_Wobject',
                        },
                        {
                                title => '1079',
                                description => '1079 description',
                                namespace => 'Asset_Wobject',
                        },
                        {
                                title => '85',
                                description => '85 description',
                                namespace => 'Asset_Wobject',
                        },
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			}
		]
	},

	'wobject delete' => {
		title => '664',
		body => '619',
		fields => [
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			}
		]
	},

	'wobject template' => {
		title => '827',
		body => '828',
		fields => [
		],
		variables => [
			{
				'name' => 'title'
			},
			{
				'name' => 'displayTitle'
			},
			{
				'name' => 'description'
			},
			{
				'name' => 'assetId'
			},
		],
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

	'wobject template variables' => {
		private => 1,
		title => 'wobject template variables title',
		body => 'wobject template variables body',
		isa => [
			{
				tag => 'asset template asset variables',
				namespace => 'Asset'
			},
		],
		fields => [
		],
		variables => [
			{
				'name' => 'displayTitle'
			},
			{
				'name' => 'description'
			},
			{
				'name' => 'styleTemplateId'
			},
			{
				'name' => 'printableStyleTemplateId'
			},
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
