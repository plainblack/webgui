package WebGUI::Help::Asset_Article;

our $HELP = {
	'article add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => 'cache timeout',
                                namespace => 'Asset_Article',
                                description => 'cache timeout help'
                        },
                        {
                                title => '72',
                                description => 'article template description',
                                namespace => 'Asset_Article',
                        },
                        {
                                title => '8',
                                description => 'link url description',
                                namespace => 'Asset_Article',
				uiLevel => 3,
                        },
                        {
                                title => '7',
                                description => 'link title description',
                                namespace => 'Asset_Article',
				uiLevel => 3,
                        },
                        {
                                title => '10',
                                description => 'carriage return description',
                                namespace => 'Asset_Article',
				uiLevel => 5,
                        },
		],
		related => [
			{
				tag => 'article template',
				namespace => 'Asset_Article'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		],
	},
	'article template' => {
		title => '72',
		body => '73',
		fields => [
		],
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Asset_Article'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
};

1;
