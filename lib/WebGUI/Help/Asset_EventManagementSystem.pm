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
                                title => 'checkout template',
                                description => 'checkout template description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'manage purchases template',
                                description => 'manage purchases template description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'view purchase template',
                                description => 'view purchase template description',
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
                        {
                                title => 'global metadata',
                                description => 'global metadata description',
                                namespace => 'Asset_EventManagementSystem',
                        },
		],
		related => [
			{
				tag => 'event management system manage events',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'event management system template',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		],
	},

	'add/edit event' => {
		title => 'add/edit event help title',
		body => 'add/edit event help body',
		fields => [
                        {
                                title => 'add/edit event title',
                                description => 'add/edit event title description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event description',
                                description => 'add/edit event description description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event price',
                                description => 'add/edit event price description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event template',
                                description => 'add/edit event template description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event start date',
                                description => 'add/edit event start date description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event end date',
                                description => 'add/edit event end date description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event maximum attendees',
                                description => 'add/edit event maximum attendees description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event required events',
                                description => 'add/edit event required events description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event operator',
                                description => 'add/edit event title description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event what next',
                                description => 'add/edit event what next description',
                                namespace => 'Asset_EventManagementSystem',
                        },
		],
		related => [
			{
				tag => 'event management system add/edit',
				namespace => 'Asset_EventManagementSystem',
			},
		],
	},

	'event management system manage events' => {
		title => 'manage events',
		body => 'manage events help body',
		fields => [
		],
		related => [
			{
				tag => 'add/edit event',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'event management system add/edit',
				namespace => 'Asset_EventManagementSystem',
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
				tag => 'event management system event template',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		],
	},

	'event management system event template' => {
		title => 'event template help title',
		body => 'event template help body',
		fields => [
		],
		related => [
			{
				tag => 'event management system add/edit',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'event management system template',
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
