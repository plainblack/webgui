package WebGUI::Help::Asset_ZipArchive;

our $HELP = {

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
