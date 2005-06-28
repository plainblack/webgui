package WebGUI::Help::Asset_SyndicatedContent;

our $HELP = {
	'syndicated content add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => '72',
                                description => '72 description',
                                namespace => 'Asset_SyndicatedContent',
                        },
                        {
                                title => 'displayModeLabel',
                                description => 'displayModeLabel description',
                                namespace => 'Asset_SyndicatedContent',
                        },
                        {
                                title => 'hasTermsLabel',
                                description => 'hasTermsLabel description',
                                namespace => 'Asset_SyndicatedContent',
                        },
                        {
                                title => '1',
                                description => '1 description',
                                namespace => 'Asset_SyndicatedContent',
                        },
                        {
                                title => '3',
                                description => '3 description',
                                namespace => 'Asset_SyndicatedContent',
                        },
		],
		related => [
			{
				tag => 'syndicated content template',
				namespace => 'Asset_SyndicatedContent'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},
	'syndicated content template' => {
		title => '72',
		body => '73',
		fields => [
		],
		related => [
			{
				tag => 'syndicated content add/edit',
				namespace => 'Asset_SyndicatedContent'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
