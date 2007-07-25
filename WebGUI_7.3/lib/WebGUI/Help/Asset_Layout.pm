package WebGUI::Help::Asset_Layout;

our $HELP = {

        'layout add/edit' => {
		title => 'layout add/edit title',
		body => 'layout add/edit body',
		fields => [
                        {
                                title => 'layout template title',
                                description => 'template description',
                                namespace => 'Asset_Layout',
                        },
                        {
                                title => 'assets to hide',
                                description => 'assets to hide description',
                                namespace => 'Asset_Layout',
				uiLevel => 9,
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'layout template',
				namespace => 'Asset_Layout'
			},
		]
	},

        'layout template' => {
		title => 'layout template title',
		body => 'layout template body',
		isa => [
			{
				namespace => "Asset_Layout",
				tag => "layout template asset variables"
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
		variables => [
		          {
		            'name' => 'showAdmin'
		          },
		          {
		            'name' => 'dragger.icon'
		          },
		          {
		            'name' => 'dragger.init'
		          },
		          {
		            'name' => 'position1_loop',
		            'variables' => [
		                             {
		                               'name' => 'id'
		                             },
		                             {
		                               'name' => 'content'
		                             }
		                           ]
		          },
		],
		fields => [
		],
		related => [
			{
				tag => 'layout add/edit',
				namespace => 'Asset_Layout'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

        'layout template asset variables' => {
		private => 1,
		title => 'layout asset template variables title',
		body => 'layout asset template variables body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject template variables"
			},
		],
		variables => [
		          {
		            'name' => 'templateId'
		          },
		          {
		            'name' => 'assetsToHide'
		          },
		          {
		            'name' => 'contentPositions'
		          },
		],
		fields => [
		],
		related => [
			{
				tag => 'layout add/edit',
				namespace => 'Asset_Layout'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

};

1;
