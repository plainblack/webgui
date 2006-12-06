package WebGUI::Help::Asset_Image;

our $HELP = {

        'image add/edit' => {
		title => 'image add/edit title',
		body => 'image add/edit body',
		isa => [
			{
				tag => 'file add/edit',
				namespace => 'Asset_File'
			},
		],
		fields => [
                        {
                                title => 'thumbnail size',
                                description => 'Thumbnail size description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'parameters',
                                description => 'Parameters description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'thumbnail',
                                description => 'Thumbnail description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'image template title',
                                description => 'image template description',
                                namespace => 'Asset_Image',
                        },
		],
		related => [
			{
				tag => 'image template',
				namespace => 'Asset_Image',
			},
			{
				tag => 'image resize',
				namespace => 'Asset_Image',
			},
		]
	},

        'image template' => {
		title => 'image template title',
		body => 'image template body',
		isa => [
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
			  {
			    'name' => 'thumbnailSize'
			  },
			  {
			    'name' => 'parameters',
			    'description' => 'parameters variable'
			  },
			  {
			    'name' => 'filename'
			  },
			  {
			    'name' => 'storageId'
			  },
			  {
			    'name' => 'title'
			  },
			  {
			    'name' => 'menuTitle'
			  }
			],
		related => [
			{
				tag => 'image add/edit',
				namespace => 'Asset_Image',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
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
			{
				tag => 'image add/edit',
				namespace => 'Asset_Image',
			},
		]
	},

};

1;
