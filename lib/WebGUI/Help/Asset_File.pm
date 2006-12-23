package WebGUI::Help::Asset_File;

our $HELP = {

        'file add/edit' => {
		title => 'file add/edit title',
		body => 'file add/edit body',
		isa => [
			{
				tag => 'asset fields',
				namespace => 'Asset',
			},
		],
		fields => [
                        {
                                title => 'cache timeout',
                                namespace => 'Asset_File',
                                description => 'cache timeout help',
                                uiLevel => 8,
                        },
			{
				title => 'current file',
				description => 'current file description',
				namespace => 'Asset_File',
			},
			{
				title => 'new file',
				description => 'new file description',
				namespace => 'Asset_File',
			},
                        {
                                title => 'file template title',
                                description => 'file template description',
                                namespace => 'Asset_File',
                        },
		],
		related => [
			{
				tag => 'file template',
				namespace => 'Asset_File',
			},
		]
	},

        'file template' => {
		title => 'file template title',
		body => 'file template body',
		isa => [
			{
				namespace => "Asset_File",
				tag => "file template asset variables"
			},
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
		],
		variables => [
			  {
			    'name' => 'fileSize'
			  },
			  {
			    'name' => 'fileIcon'
			  },
			  {
			    'name' => 'fileUrl'
			  },
			  {
			    'name' => 'controls'
			  },
			],
		fields => [
		],
		related => [
			{
				tag => 'file add/edit',
				namespace => 'Asset_File',
			},
		]
	},

        'file template asset variables' => {
		title => 'file template asset var title',
		body => 'file template asset var body',
		isa => [
			{
				namespace => "Asset",
				tag => "asset template asset variables"
			},
		],
		variables => [
			  {
			    'name' => 'cacheTimeout'
			  },
			  {
			    'name' => 'filename',
			    'description' => 'filename var'
			  },
			  {
			    'name' => 'storageId'
			  },
			  {
			    'name' => 'templateId'
			  },
			],
		fields => [
		],
		related => [
			{
				tag => 'file add/edit',
				namespace => 'Asset_File',
			},
		]
	},

};

1;
