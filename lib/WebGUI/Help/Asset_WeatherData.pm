package WebGUI::Help::Asset_Article;

our $HELP = {
	'article add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => '72',
                                description => 'article template description',
                                namespace => 'Asset_Article',
                        },
                        {
                                title => '7',
                                description => 'link title description',
                                namespace => 'Asset_Article',
                        },
                        {
                                title => '8',
                                description => 'link url description',
                                namespace => 'Asset_Article',
                        },
                        {
                                title => '10',
                                description => 'carriage return description',
                                namespace => 'Asset_Article',
                        },
		],
		related => [
			{
				tag => 'article template',
				namespace => 'Asset_Article'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
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
				namespace => 'Wobject'
			}
		]
	},
};

1;
