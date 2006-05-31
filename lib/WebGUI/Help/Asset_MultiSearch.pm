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
		isa => [
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
			{
				namespace => "Asset",
				tag => "asset template"
			},
		],
		variables => [
		          {
		            'name' => 'search',
		            'description' => 'search.variable'
		          },
		          {
		            'name' => 'for',
		            'description' => 'for.variable'
		          },
		          {
		            'name' => 'submit'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'multi search add/edit',
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
