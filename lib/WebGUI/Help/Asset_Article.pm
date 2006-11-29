package WebGUI::Help::Asset_Article;

our $HELP = {
	'article add/edit' => {
		title => '61',
		body => '71',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit"
			},
		],
		fields => [
                        {
                                title => 'cache timeout',
                                namespace => 'Asset_Article',
                                description => 'cache timeout help',
				uiLevel => 8,
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
		],
	},

	'article template' => {
		title => '72',
		body => '73',
		isa => [
			{
				namespace => "Asset_Article",
				tag => "article asset template variables"
			},
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
			{
				namespace => "Asset",
				tag => "asset template"
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'new.template'
		          },
		          {
		            'name' => 'description'
		          },
		          {
		            'name' => 'description.full'
		          },
		          {
		            'name' => 'description.first.100words'
		          },
		          {
		            'name' => 'description.first.75words'
		          },
		          {
		            'name' => 'description.first.50words'
		          },
		          {
		            'name' => 'description.first.25words'
		          },
		          {
		            'name' => 'description.first.10words'
		          },
		          {
		            'name' => 'description.first.paragraph'
		          },
		          {
		            'name' => 'description.first.2paragraphs'
		          },
		          {
		            'name' => 'description.first.sentence'
		          },
		          {
		            'name' => 'description.first.2sentences'
		          },
		          {
		            'name' => 'description.first.3sentences'
		          },
		          {
		            'name' => 'description.first.4sentences'
		          },
		          {
		            'name' => 'attachment.icon'
		          },
		          {
		            'name' => 'attachment.name'
		          },
		          {
		            'name' => 'attachment.url'
		          },
		          {
		            'name' => 'image.thumbnail'
		          },
		          {
		            'name' => 'image.url'
		          },
		          {
		            'name' => 'attachment_loop',
		            'variables' => [
		                             {
		                               'name' => 'filename'
		                             },
		                             {
		                               'name' => 'url'
		                             },
		                             {
		                               'name' => 'thumbnailUrl'
		                             },
		                             {
		                               'name' => 'iconUrl'
		                             },
		                             {
		                               'name' => 'isImage'
		                             }
		                           ]
		          },
		        ],
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Asset_Article'
			},
		]
	},

	'article asset template variables' => {
		title => 'article asset template variables title',
		body => 'article asset template variables body',
		isa => [
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'linkTitle'
		          },
		          {
		            'name' => 'linkURL'
		          },
		          {
		            'name' => 'cacheTimeout'
		          },
		          {
		            'name' => 'templateId'
		          },
		          {
		            'name' => 'storageId'
		          },
		        ],
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Asset_Article'
			},
		]
	},

};

1;
