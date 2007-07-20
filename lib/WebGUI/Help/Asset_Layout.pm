package WebGUI::Help::Asset_Layout;

our $HELP = {

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
		]
	},

};

1;
