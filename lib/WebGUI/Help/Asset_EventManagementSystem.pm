package WebGUI::Help::Asset_EventManagementSystem; ## Be sure to change the package name to match your filename.

##Stub document for creating help documents.

our $HELP = {
	'event management system add/edit' => {
		source => 'sub definition',
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
                                title => 'search template',
                                description => 'search template description',
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
		source => 'sub www_editEvent',
		title => 'add/edit event help title',
		body => 'add/edit event help body',
		fields => [
                        {
                                title => 'approve event',
                                description => 'approve event description',
                                namespace => 'Asset_EventManagementSystem',
                        },
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
                                title => 'add/edit event image',
                                description => 'add/edit event image description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'price',
                                description => 'add/edit event price description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'add/edit event template',
                                description => 'add/edit event template description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'weight',
                                description => 'weight description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'sku',
                                description => 'sku description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'sku template',
                                description => 'sku template',
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
                                title => 'assigned prerequisite set',
                                description => 'assigned prerequisite set description',
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

	'edit event metadata field' => {
		source => 'sub www_editEventMetaDataField',
		title => 'add/edit event metadata field',
		body => 'add/edit event metadata field body',
		fields => [
                        {
                                title => '475',
                                description => '475 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '472',
                                description => '472 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '473a',
                                description => '473a description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '474',
                                description => '474 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '486',
                                description => '486 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '487',
                                description => '487 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '488',
                                description => '488 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => 'auto search',
                                description => 'auto search description',
                                namespace => 'Asset_EventManagementSystem',
                        },
		],
		related => [
			{
				tag => 'event management system add/edit',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'add/edit event',
				namespace => 'Asset_EventManagementSystem',
			},
		],
	},

	'event management system template' => {
		source => 'sub view',
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
				tag => 'pagination template variables',
				namespace => 'WebGUI',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		],
	},

	'event management system event template' => {
		source => 'sub www_editEvent',
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

	'ems manage purchases template' => {
		source => 'sub www_managePurchases',
		title => 'manage purchases template help title',
		body => 'manage purchases template help body',
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

	'ems view purchase template' => {
		source => 'sub www_viewPurchases',
		title => 'view purchase template help title',
		body => 'view purchase template help body',
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


	'ems search template' => {
		source => 'sub www_search',
		title => 'search template help title',
		body => 'search template help body',
		fields => [
		],
		related => [
			{
				tag => 'event management system add/edit',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		],
	},

};

1;  ##All perl modules must return true
