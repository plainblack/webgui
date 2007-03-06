package WebGUI::Help::Asset_HttpProxy;

our $HELP = {
	'http proxy add/edit' => {
		title => '10',
		body => '11',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject add/edit',
			},
		],
		fields => [
                        {
                                title => '1',
                                description => '1 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '5',
                                description => '5 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '8',
                                description => '8 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '12',
                                description => '12 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => 'http proxy template title',
                                description => 'http proxy template title description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => 'cache timeout',
                                description => 'cache timeout description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => 'use ampersand',
                                description => 'use ampersand help',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '6',
                                description => '6 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '418',
                                description => '418 description',
                                namespace => 'WebGUI',
                        },
                        {
                                title => '4',
                                description => '4 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '13',
                                description => '13 description',
                                namespace => 'Asset_HttpProxy',
                        },
                        {
                                title => '14',
                                description => '14 description',
                                namespace => 'Asset_HttpProxy',
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset',
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Asset_Wobject',
			},
			{
				tag => 'http proxy template',
				namespace => 'Asset_HttpProxy',
			},
			{
				tag => 'content filtering',
				namespace => 'WebGUI',
			},
		],
	},

	'http proxy template' => {
		title => 'http proxy template title',
		body => 'http proxy template body',
		isa => [
			{
				namespace => 'Asset_HttpProxy',
				tag => 'http proxy asset template variables',
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
		fields => [
		],
		variables => [
		          {
		            'name' => 'header',
		          },
		          {
		            'name' => 'content',
		          },
		          {
		            'name' => 'search.for',
		          },
		          {
		            'name' => 'stop.at',
		          },
		          {
		            'name' => 'content.leading',
		          },
		          {
		            'name' => 'content.trailing',
		          },
		],
		related => [
			{
				tag => 'http proxy add/edit',
				namespace => 'Asset_HttpProxy',
			},
		],
	},

	'http proxy asset template variables' => {
		private => 1,
		title => 'http proxy asset template variables title',
		body => 'http proxy asset template variables body',
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
		            'name' => 'templateId',
		          },
		          {
		            'name' => 'proxiedUrl',
		          },
		          {
		            'name' => 'useAmpersand',
		          },
		          {
		            'name' => 'timeout',
		          },
		          {
		            'name' => 'removeStyle',
		          },
		          {
		            'name' => 'cacheTimeout',
		          },
		          {
		            'name' => 'filterHtml',
		          },
		          {
		            'name' => 'followExternal',
		          },
		          {
		            'name' => 'rewriteUrls',
		          },
		          {
		            'name' => 'followRedirect',
		          },
		          {
		            'name' => 'searchFor',
		          },
		          {
		            'name' => 'stopAt',
		          },
		          {
		            'name' => 'cookieJarStorageId',
		          },
		        ],
		related => [
		],
	},

};

1;
