package WebGUI::Help::Asset_Search;

our $HELP = {
	'search add/edit' => {
		title => 'add/edit title',
		body => 'add/edit body',
		isa => [
		],
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
		],
		related => [
			{
				tag => 'search template',
				namespace => 'Asset_Search'
			},
		]
	},

	'search template' => {
		title => 'search template',
		body => 'search template body',
		isa => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				namespace => "Asset_Search",
				tag => "search asset template variables"
			},
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
			{
				namespace => "Asset",
				tag => "asset template"
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'form_header',
			    required => 1,
		          },
		          {
		            'name' => 'form_footer',
			    required => 1,
		          },
		          {
		            'name' => 'form_submit',
			    required => 1,
		          },
		          {
		            'name' => 'form_keywords',
			    required => 1,
		          },
		          {
		            'name' => 'result_set',
			    required => 1,
			    variables => [
				  {
				    'name' => 'url',
				  },
				  {
				    'name' => 'title',
				  },
				  {
				    'name' => 'synopsis',
				  },
				  {
                                    'name' => 'assetId',
                                  },
			    ],
		          },
		          {
		            'name' => 'results_found',
		          },
		          {
		            'name' => 'no_results',
		          },
		],
		related => [
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			},
		]
	},

	'search asset template variables' => {
		private => 1,
		title => 'search asset template variables title',
		body => 'search asset template variables body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject template variables"
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'templateId'
		          },
		          {
		            'name' => 'searchRoot'
		          },
		          {
		            'name' => 'classLimiter'
		          },
		        ],
		related => [
		]
	},

};

1;
