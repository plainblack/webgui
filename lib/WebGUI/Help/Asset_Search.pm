package WebGUI::Help::Asset_Search;

our $HELP = {
	'search add/edit' => {
		title => 'add/edit title',
		body => 'add/edit body',
		fields => [
                        {
                                title => 'search template',
                                description => 'search template description',
                                namespace => 'Asset_Search',
                        },
                        {
                                title => 'search root',
                                description => 'search root description',
                                namespace => 'Asset_Search',
                        },
                        {
                                title => 'class limiter',
                                description => 'class limiter description',
                                namespace => 'Asset_Search',
                        },
                        {
                                title => 'view template',
                                description => 'view template description',
                                namespace => 'Asset_Search',
                        },
		],
		related => [
			{
				tag => 'search template',
				namespace => 'Asset_Search'
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
		]
	},
	'search template' => {
		title => 'search template',
		body => 'search template body',
		fields => [
                        {
                                title => 'search template',
                                description => 'search template description',
                                namespace => 'Asset_Search',
                        },
                        {
                                title => 'search root',
                                description => 'search root description',
                                namespace => 'Asset_Search',
                        },
                        {
                                title => 'class limiter',
                                description => 'class limiter description',
                                namespace => 'Asset_Search',
                        },
                        {
                                title => 'view template',
                                description => 'view template description',
                                namespace => 'Asset_Search',
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
			},
		]
	},
};

1;
