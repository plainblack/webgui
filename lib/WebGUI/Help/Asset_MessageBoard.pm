package WebGUI::Help::Asset_MessageBoard;

our $HELP = {
	'message board add/edit' => {
		title => '61',
		body => '71',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject add/edit',
			},
		],
		fields => [
                        {
                                title => 'visitor cache timeout',
                                namespace => 'Asset_MessageBoard',
                                description => 'visitor cache timeout help',
				uiLevel => 8
                        },
                        {
                                title => '73',
                                namespace => 'Asset_MessageBoard',
                                description => '73 description',
                        },
		],
		related => [
			{
				tag => 'message board template',
				namespace => 'Asset_MessageBoard',
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject',
			},
		],
	},

	'message board template' => {
		title => '73',
		body => '74',
		isa => [
			{
				namespace => 'Asset_MessageBoard',
				tag => 'message board asset template variables',
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
		            'name' => 'forum.add.url',
		          },
		          {
		            'name' => 'forum.add.label',
		          },
		          {
		            'name' => 'title.label',
		          },
		          {
		            'name' => 'views.label',
		          },
		          {
		            'name' => 'rating.label',
		          },
		          {
		            'name' => 'threads.label',
		          },
		          {
		            'name' => 'replies.label',
		          },
		          {
		            'name' => 'lastpost.label',
		          },
		          {
		            'name' => 'forum_loop',
		            'variables' => [
		                             {
		                               'name' => 'forum.controls',
		                             },
		                             {
		                               'name' => 'forum.count',
		                             },
		                             {
		                               'name' => 'forum.title',
		                             },
		                             {
		                               'name' => 'forum.description',
		                             },
		                             {
		                               'name' => 'forum.replies',
		                             },
		                             {
		                               'name' => 'forum.rating',
		                             },
		                             {
		                               'name' => 'forum.views',
		                             },
		                             {
		                               'name' => 'forum.threads',
		                             },
		                             {
		                               'name' => 'forum.url',
		                             },
		                             {
		                               'name' => 'forum.lastpost.url',
		                             },
		                             {
		                               'name' => 'forum.lastpost.date',
		                             },
		                             {
		                               'name' => 'forum.lastpost.time',
		                             },
		                             {
		                               'name' => 'forum.lastpost.epoch',
		                             },
		                             {
		                               'name' => 'forum.lastpost.subject',
		                             },
		                             {
		                               'name' => 'forum.lastpost.user.hasread',
		                             },
		                             {
		                               'name' => 'forum.lastpost.user.id',
		                             },
		                             {
		                               'name' => 'forum.lastpost.user.name',
		                             },
		                             {
		                               'name' => 'forum.lastpost.user.alias',
		                             },
		                             {
		                               'name' => 'forum.lastpost.user.profile',
		                             },
		                             {
		                               'name' => 'forum.lastpost.user.isVisitor',
		                             },
		                             {
		                               'name' => 'forum.user.canView',
		                             },
		                             {
		                               'name' => 'forum.user.canPost',
		                             },
		                           ],
		          },
		          {
		            'name' => 'default.listing',
		          },
		          {
		            'name' => 'areMultipleForums',
		          },
		        ],
		fields => [
		],
		related => [
		],
	},

	'message board asset template variables' => {
		title => 'message board asset template variables title',
		body => 'message board asset template variables body',
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
		            'name' => 'visitorCacheTimeout',
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
