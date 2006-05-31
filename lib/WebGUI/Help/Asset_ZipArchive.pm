package WebGUI::Help::Asset_ZipArchive;

our $HELP = {

        'zip archive add/edit' => {
		title => 'zip archive add/edit title',
		body => 'zip archive add/edit body',
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
				tag => 'asset fields',
				namespace => 'Asset',
			},
			{
				tag => 'zip archive template',
				namespace => 'Asset_ZipArchive',
			},
			{
				tag => 'file add/edit',
				namespace => 'Asset_File',
			},
		]
	},

    'zip archive template' => {
		title => 'zip archive template title',
		body => 'zip archive template body',
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
		            'name' => 'controls'
		          },
		          {
		            'name' => 'error'
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

};

1;
