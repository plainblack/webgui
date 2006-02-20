package WebGUI::Help::Asset_EventManagementSystem; ## Be sure to change the package name to match your filename.

##Stub document for creating help documents.

our $HELP = {
	'event management system add/edit' => {
		title => 'add/edit help title',
		body => 'add/edit help body',
		fields => [
                        {
                                title => 'display template',
                                description => 'display template description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'paginate after',
                                description => 'paginate after description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'group to add events',
                                description => 'group to add events description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'group to approve events',
                                description => 'group to approve events description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'global prerequisite',
                                description => 'global prerequisite description',
                                namespace => 'Asset_EventManagementSystem',
                        },
		],
		related => [
			{
				tag => 'event management system add/edit',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		],
	},

	'event management system template' => {
		title => 'template help title',
		body => 'template help body',
		fields => [
		],
		related => [
			{
				tag => 'event management system add/edit',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		],
	},

};

1;  ##All perl modules must return true
