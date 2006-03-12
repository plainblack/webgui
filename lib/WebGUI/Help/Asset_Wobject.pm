package WebGUI::Help::Asset_Wobject;

our $HELP = {

	'wobjects using' => {
		title => '671',
		body => '626',
		fields => [
		],
		related => [
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
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
                        {
                                title => '895',
                                description => '895 description',
                                namespace => 'Asset_Wobject',
				uiLevel => 8,
                        },
                        {
                                title => '896',
                                description => '896 description',
                                namespace => 'Asset_Wobject',
				uiLevel => 8,
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
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
};

1;
