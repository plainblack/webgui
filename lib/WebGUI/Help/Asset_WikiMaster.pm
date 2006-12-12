package WebGUI::Help::Asset_WikiMaster;

our $HELP = {
	'wiki master add/edit' => {
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
                                title => 'groupToEditPages label',
                                description => 'groupToEditPages hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'groupToAdminister label',
                                description => 'groupToAdminister hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'richEditor label',
                                description => 'richEditor hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'frontPageTemplateId label',
                                description => 'frontPageTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'pageTemplateId label',
                                description => 'pageTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'pageHistoryTemplateId label',
                                description => 'pageHistoryTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'mostPopularTemplateId label',
                                description => 'mostPopularTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'recentChangesTemplateId label',
                                description => 'recentChangesTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'searchTemplateId label',
                                description => 'searchTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'pageEditTemplateId label',
                                description => 'pageEditTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'recentChangesCount label',
                                description => 'recentChangesCount hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'recentChangesCountFront label',
                                description => 'recentChangesCountFront hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'mostPopularCountFront label',
                                description => 'mostPopularCountFront hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'approval workflow',
                                description => 'approval workflow description',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'thumbnail size',
                                description => 'thumbnail size help',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'max image size',
                                description => 'max image size help',
                                namespace => 'Asset_WikiMaster',
                        },
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
		],
	},

	'wiki master search box variables' => {
		title => 'search box variables title',
		body => 'search box variables body',
		isa => [
		],
		variables => [
		          {
		            'name' => 'searchFormHeader',
		          },
		          {
		            'name' => 'searchQuery',
		          },
		          {
		            'name' => 'searchSubmit',
		          },
		          {
		            'name' => 'searchFormFooter',
		          },
		],
		fields => [
		],
		related => [
		],
	},

	'wiki master recent changes variables' => {
		title => 'recent changes variables title',
		body => 'recent changes variables body',
		isa => [
		],
		variables => [
		          {
		            'name' => 'recentChanges',
			    'variables' => [
				  {
				    'name' => 'title',
				    'description' => 'recent changes title',
				  },
				  {
				    'name' => 'url',
				    'description' => 'recent changes url',
				  },
				  {
				    'name' => 'actionTaken',
				  },
				  {
				    'name' => 'username',
				    'description' => 'recent changes username',
				  },
				  {
				    'name' => 'date',
				    'description' => 'recent changes date',
				  },
			    ]
		          },
		],
		fields => [
		],
		related => [
		],
	},

	'wiki master most popular variables' => {
		title => 'most popular variables title',
		body => 'most popular variables body',
		isa => [
		],
		variables => [
		          {
		            'name' => 'mostPopular',
			    'variables' => [
				  {
				    'name' => 'title',
				    'description' => 'most popular title',
				  },
				  {
				    'name' => 'url',
				    'description' => 'most popular url',
				  },
			    ]
		          },
		],
		fields => [
		],
		related => [
		],
	},

	'front page template' => {
		title => 'front page template title',
		body => 'front page template body',
		isa => [
			{
				namespace => "Asset_WikiMaster",
				tag => "wiki master most popular variables"
			},
			{
				namespace => "Asset_WikiMaster",
				tag => "wiki master recent changes variables"
			},
			{
				namespace => "Asset_WikiMaster",
				tag => "wiki master search box variables"
			},
			{
				namespace => "Asset_WikiMaster",
				tag => "wiki master asset variables"
			},
		],
		variables => [
			  {
			    'name' => 'searchLabel',
			    'description' => 'searchLabel variable',
			  },
			  {
			    'name' => 'mostPopularUrl',
			  },
			  {
			    'name' => 'mostPopularLabel',
			  },
			  {
			    'name' => 'recentChangesUrl',
			  },
			  {
			    'name' => 'recentChangesLabel',
			  },
		],
		fields => [
		],
		related => [
		],
	},

	'wiki master asset variables' => {
		title => 'wiki master asset variables title',
		body => 'wiki master asset variables body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject template"
			},
			{
				namespace => "Asset",
				tag => "asset template"
			},
		],
		variables => [
			  {
			    'name' => 'groupToEditPages',
			  },
			  {
			    'name' => 'groupToAdminister',
			  },
			  {
			    'name' => 'richEditor',
			  },
			  {
			    'name' => 'frontPageTemplateId',
			  },
			  {
			    'name' => 'pageTemplateId',
			  },
			  {
			    'name' => 'pageHistoryTemplateId',
			  },
			  {
			    'name' => 'mostPopularTemplateId',
			  },
			  {
			    'name' => 'recentChangesTemplateId',
			  },
			  {
			    'name' => 'searchTemplateId',
			  },
			  {
			    'name' => 'recentChangesCount',
			    'description' => 'recentChangesCount hoverHelp',
			  },
			  {
			    'name' => 'recentChangesCountFront',
			    'description' => 'recentChangesCountFront hoverHelp',
			  },
			  {
			    'name' => 'mostPopularCount',
			    'description' => 'mostPopularCount hoverHelp',
			  },
			  {
			    'name' => 'mostPopularCountFront',
			    'description' => 'mostPopularCountFront hoverHelp',
			  },
			  {
			    'name' => 'approvalWorkflow',
			  },
			  {
			    'name' => 'thumbnailSize',
			  },
			  {
			    'name' => 'maxImageSize',
			  },
		],
		fields => [
		],
		related => [
		],
	},

	'most popular template' => {
		title => 'most popular template title',
		body => 'most popular template body',
		isa => [
			{
				namespace => "Asset_WikiMaster",
				tag => "wiki master most popular variables"
			},
		],
		variables => [
			  {
			    'name' => 'title',
			    'description' => 'most popular title variable',
			  },
			  {
			    'name' => 'recentChangesUrl',
			  },
			  {
			    'name' => 'recentChangesLabel',
			  },
			  {
			    'name' => 'searchLabel',
			    'description' => 'searchLabel variable',
			  },
			  {
			    'name' => 'searchLabelUrl',
			  },
			  {
			    'name' => 'wikiHomeLabel',
			    'description' => 'wikiHomeLabel variable',
			  },
			  {
			    'name' => 'wikiHomeUrl',
			  },
		],
		fields => [
		],
		related => [
		],
	},

	'recent changes template' => {
		title => 'recent changes template title',
		body => 'recent changes template body',
		isa => [
			{
				namespace => "Asset_WikiMaster",
				tag => "wiki master recent changes variables"
			},
		],
		variables => [
			  {
			    'name' => 'title',
			    'description' => 'recent changes title',
			  },
			  {
			    'name' => 'searchLabel',
			    'description' => 'searchLabel variable',
			  },
			  {
			    'name' => 'searchLabelUrl',
			  },
			  {
			    'name' => 'wikiHomeLabel',
			    'description' => 'wikiHomeLabel variable',
			  },
			  {
			    'name' => 'wikiHomeUrl',
			  },
			  {
			    'name' => 'mostPopularUrl',
			  },
			  {
			    'name' => 'mostPopularLabel',
			  },
		],
		fields => [
		],
		related => [
		],
	},

	'search template' => {
		title => 'search template title',
		body => 'search template body',
		isa => [
			{
				namespace => "Asset_WikiMaster",
				tag => "wiki master search box variables"
			},
		],
		variables => [
			  {
			    'name' => 'searchLabel',
			    'description' => 'searchLabel variable',
			  },
			  {
			    'name' => 'searchLabelUrl',
			  },
			  {
			    'name' => 'wikiHomeLabel',
			    'description' => 'wikiHomeLabel variable',
			  },
			  {
			    'name' => 'wikiHomeUrl',
			  },
			  {
			    'name' => 'mostPopularUrl',
			  },
			  {
			    'name' => 'mostPopularLabel',
			  },
			  {
			    'name' => 'recentChangesUrl',
			  },
			  {
			    'name' => 'recentChangesLabel',
			  },
			  {
			    'name' => 'resultsLabel',
			  },
			  {
			    'name' => 'notWhatYouWanted variable',
			  },
			  {
			    'name' => 'nothingFoundLabel variable',
			  },
			  {
			    'name' => 'addPageUrl',
			  },
			  {
			    'name' => 'addPageLabel',
			  },
			  {
			    'name' => 'performSearch',
			  },
			  {
			    'name' => 'searchResults',
			    variables => [
				  {
				    'name' => 'search url variable',
				  },
				  {
				    'name' => 'search title variable',
				  },
			    ],
			  },
		],
		fields => [
		],
		related => [
		],
	},

};

1;
