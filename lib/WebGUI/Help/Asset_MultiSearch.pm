package WebGUI::Help::Asset_MultiSearch;

our $HELP = {
	'multi search add/edit' => {
		title => 'multisearch add/edit title',
		body => 'multisearch add/edit body',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject add/edit',
			},
		],
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
				namespace => 'Asset_MultiSearch',
			},
			{
				tag => 'dashboard add/edit',
				namespace => 'Asset_Dashboard',
			},
		],
	},

	'multisearch template' => {
		title => 'multisearch template title',
		body => 'multisearch template body',
		isa => [
			{
				namespace => 'Asset_MultiSearch',
				tag => 'multi search asset template variables',
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables',
			},
			{
				namespace => 'Asset',
				tag => 'asset template',
			},
		],
		variables => [
		          {
		            'name' => 'search',
		            'description' => 'search.variable',
		          },
		          {
		            'name' => 'for',
		            'description' => 'for.variable',
		          },
		          {
		            'name' => 'submit',
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'multi search add/edit',
				namespace => 'Asset_MultiSearch',
			},
		],
	},

	'multi search asset template variables' => {
		title => 'multi search asset template variables title',
		body => 'multi search asset template variables body',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject template variables',
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'cacheTimeout',
		          },
		          {
		            'name' => 'templateId',
		          },
		        ],
		related => [
		],
	},
};

1;
