package WebGUI::Help::Asset_ZipArchive;

our $HELP = {

        'zip archive add/edit' => {
		title => 'zip archive add/edit title',
		body => 'zip archive add/edit body',
		isa => [
			{
				namespace => "Asset_File",
				tag => "file add/edit"
			},
		],
		fields => [
			{
				title => 'new file',
				description => 'new file description',
				namespace => 'Asset_File',
			},
			{
				title => 'current file',
				description => 'current file description',
				namespace => 'Asset_File',
			},
			{
				title => 'show page',
				description => 'show page description',
				namespace => 'Asset_ZipArchive',
			},
			
		],
		related => [
			{
				tag => 'zip archive template',
				namespace => 'Asset_ZipArchive',
			},
		]
	},

    'zip archive template' => {
		title => 'zip archive template title',
		body => 'zip archive template body',
		isa => [
			{
				namespace => "Asset_ZipArchive",
				tag => "zip archive asset variables"
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
		            'name' => 'controls'
		          },
		          {
		            'name' => 'error'
		          },
		          {
		            'name' => 'noInitialPage var'
		          },
		          {
		            'name' => 'noFileSpecified var'
		          },
		          {
		            'name' => 'fileUrl'
		          },
		          {
		            'name' => 'fileIcon'
		          }
		        ],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

    'zip archive asset variables' => {
		private => 1,
		title => 'zip archive asset variables title',
		body => 'zip archive asset variables body',
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
		            'name' => 'showPage'
		          },
		          {
		            'name' => 'templateId'
		          },
		        ],
		related => [
		]
	},

};

1;
