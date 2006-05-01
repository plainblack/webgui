package WebGUI::Help::Asset_MultiSearch;

our $HELP = {
	'multi search add/edit' => {
		title => 'multisearch add/edit title',
		body => 'multisearch add/edit body',
		fields => [
                        {
                                title => 'cache timeout',
                                namespace => 'Asset_MultiSearch',
                                description => 'cache timeout help',
				uiLevel => 8,
                        },
                        {
                                title => 'MultiSearch Template',
                                description => 'MultiSearch Template description',
                                namespace => 'Asset_MultiSearch',
                        },
		],
		related => [
			{
				tag => 'multisearch template',
				namespace => 'Asset_MultiSearch'
			},
			{
				tag => 'dashboard add/edit',
				namespace => 'Asset_Dashboard'
			},
		]
	},

	'multisearch template' => {
		title => 'multisearch template title',
		body => 'multisearch template body',
		fields => [
		],
		related => [
			{
				tag => 'multisearch template',
				namespace => 'Asset_MultiSearch'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	}
};

1;
