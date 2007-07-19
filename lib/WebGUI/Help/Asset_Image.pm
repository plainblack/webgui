package WebGUI::Help::Asset_Image;

our $HELP = {

        'image template' => {
		title => 'image template title',
		body => '',
		isa => [
			{
				namespace => "Asset_Image",
				tag => "image template asset variables"
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
			    'name' => 'fileIcon'
			  },
			  {
			    'name' => 'fileUrl'
			  },
			  {
			    'name' => 'controls'
			  },
			  {
			    'name' => 'thumbnail',
			    'description' => 'thumbnail variable'
			  },
			],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

        'image template asset variables' => {
		private => 1,
		title => 'image template asset var title',
		body => '',
		isa => [
			{
				namespace => "Asset_File",
				tag => "file template asset variables"
			},
		],
		fields => [
		],
		variables => [
			  {
			    'name' => 'thumbnailSize'
			  },
			  {
			    'name' => 'parameters',
			    'description' => 'parameters variable'
			  },
			],
		related => [
		]
	},

        'image resize' => {
		title => 'resize image title',
		body => 'resize image body',
		fields => [
                        {
                                title => 'image size',
                                description => 'image size description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'new width',
                                description => 'new width description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'new height',
                                description => 'new height description',
                                namespace => 'Asset_Image',
                        },
		],
		related => [
		]
	},

};

1;
