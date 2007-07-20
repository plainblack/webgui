package WebGUI::Help::Asset_Folder;

our $HELP = {

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
		]
	},

        'folder template asset variables' => {
		private => 1,
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
		]
	},

};

1;
