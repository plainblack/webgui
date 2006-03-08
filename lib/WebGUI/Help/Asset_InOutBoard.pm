package WebGUI::Help::Asset_InOutBoard;

our $HELP = {
	'in out board add/edit' => {
		title => '18',
		body => '19',
		fields => [
                        {
                                title => '1',
                                description => '1 description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => '12',
                                description => '12 description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => 'In Out Template',
                                description => 'In Out Template description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => '13',
                                description => '13 description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => '3',
                                description => '3 description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => 'inOutGroup',
                                description => 'inOutGroup description',
                                namespace => 'Asset_InOutBoard',
                        },
		],
		related => [
			{
				tag => 'in out board template',
				namespace => 'Asset_InOutBoard'
			},
			{
				tag => 'in out board report template',
				namespace => 'Asset_InOutBoard'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'in out board template' => {
		title => '20',
		body => '21',
		related => [
			{
				tag => 'in out board add/edit',
				namespace => 'Asset_InOutBoard'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'in out board report template' => {
		title => '22',
		body => '23',
		related => [
			{
				tag => 'in out board add/edit',
				namespace => 'Asset_InOutBoard'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			}
		]
	},
};

1;

