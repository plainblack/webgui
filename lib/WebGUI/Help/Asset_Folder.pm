package WebGUI::Help::Asset_Folder;

our $HELP = {

        'folder add/edit' => {
		title => 'folder add/edit title',
		body => 'folder add/edit body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit",
			},
		],
		fields => [
                        {
                                title => 'visitor cache timeout',
                                namespace => 'Asset_Folder',
                                description => 'visitor cache timeout help',
				uiLevel => 8,
                        },
                        {
                                title => 'folder template title',
                                description => 'folder template description',
				namespace => 'Asset_Folder',
                        },
                        {
                                title => 'sort alphabetically',
                                description => 'sort alphabetically help',
				namespace => 'Asset_Folder',
                        },
		],
		related => [
			{
				tag => 'folder template',
				namespace => 'Asset_Folder',
			},
		]
	},

        'folder template' => {
		title => 'folder template title',
		body => 'folder template body',
		isa => [
			{
				namespace => "Asset_Folder",
				tag => "folder template asset variables"
			},
		],
		fields => [ ],
		variables => [
			{
				name => 'addFile.url',
			}, {
				name => "addFile.label",
			}, {
				name => "subfolder_loop",
				variables => [
					{
						name => "id",
						description => "folder id"
					}, {
						name => "url",
						description => "folder url"
					}, {
						name => "title",
						description => "folder title"
					}, {
						name => "icon.small",
						description => "folder icon.small"
					}, {
						name => "icon.big",
						description => "folder icon.big"
					}
				]
			}, {
				name => "file_loop",
				variables => [
					{
						name => "id",
					}, {
						name => "canView",
					}, {
						name => "title",
					}, {
						name => "synopsis",
					}, {
						name => "size",
					}, {
						name => "date.epoch",
					}, {
						name => "icon.small",
					}, {
						name => "icon.big",
					}, {
						name => "type",
					}, {
						name => "url",
					}, {
						name => "isImage",
					}, {
						name => "canEdit",
					}, {
						name => "controls",
					}, {
						name => "isFile",
					}, {
						name => "thumbnail.url",
					}, {
						name => "file.url",
					}
				],	
			}
		],
		related => [
			{
				tag => 'folder add/edit',
				namespace => 'Asset_Folder',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

        'folder template asset variables' => {
		title => 'asset template variables title',
		body => 'asset template variables body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject template variables"
			},
		],
		fields => [ ],
		variables => [
			{
				name => 'sortAlphabetically',
			},
			{
				name => 'templateId',
			},
			{
				name => 'visitorCacheTimeout',
			},
		],
		related => [
			{
				tag => 'folder add/edit',
				namespace => 'Asset_Folder',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

};

1;
