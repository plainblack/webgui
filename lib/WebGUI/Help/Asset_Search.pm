package WebGUI::Help::Asset_Search;

our $HELP = {
	'search add/edit' => {
		title => 'add/edit title',
		body => 'add/edit body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit"
			},
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
		          }
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			}
		]
	},
};

1;
