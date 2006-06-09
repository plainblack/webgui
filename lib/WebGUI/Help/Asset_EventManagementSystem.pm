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

	'edit event prerequisite set' => {
		source => 'sub www_editPrereqSet',
		title => 'edit prerequisite set',
		body => 'edit prerequisite set body',
		fields => [
                        {
                                title => 'prereq set name field label',
                                description => 'prereq set name field description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'operator type',
                                description => 'operator type description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'events required by this prerequisite set',
                                description => 'events required by description',
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

	'edit discount pass' => {
		source => 'sub www_editDiscountPass',
		title => 'edit discount pass',
		body => 'edit discount pass body',
		fields => [
                        {
                                title => 'discount pass id',
                                description => 'discount pass id description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'pass name',
                                description => 'pass name description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'discount pass type',
                                description => 'discount pass type description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'discount amount',
                                description => 'discount amount description',
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

	'manage discount passes' => {
		source => 'sub www_manageDiscountPass',
		title => 'manage discount passes',
		body => 'manage discount pass body',
		fields => [
		],
		related => [
			{
				tag => 'edit discount pass',
				namespace => 'Asset_EventManagementSystem',
			},
			{
				tag => 'event management system add/edit',
				namespace => 'Asset_EventManagementSystem',
			},
		],
	},

	'edit registrant' => {
		source => 'sub www_editRegistrant',
		title => 'edit registrant',
		body => 'edit registrant body',
		fields => [
                        {
                                title => 'associated user',
                                description => 'associated user description',
                                namespace => 'Asset_EventManagementSystem',
                        },
                        {
                                title => 'created by',
                                description => 'created by description',
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
		variables => [
		          {
		            'name' => 'checkout.url'
		          },
		          {
		            'name' => 'checkout.label'
		          },
		          {
		            'name' => 'events_loop',
		            'variables' => [
		                             {
		                               'name' => 'event',
		                               'description' => 'tmplVar event'
		                             }
		                           ]
		          },
		          {
		            'name' => 'paginateBar'
		          },
		          {
		            'name' => 'Pagination variables'
		          },
		          {
		            'name' => 'canManageEvents'
		          },
		          {
		            'name' => 'manageEvents.url'
		          },
		          {
		            'name' => 'manageEvents.label'
		          },
		          {
		            'name' => 'managePurchases.url'
		          },
		          {
		            'name' => 'managePurchases.label'
		          }
		],
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
		variables => [
		          {
		            'name' => 'title'
		          },
		          {
		            'name' => 'title.url'
		          },
		          {
		            'name' => 'description'
		          },
		          {
		            'name' => 'image'
		          },
		          {
		            'name' => 'price',
		            'description' => 'tmplVar price'
		          },
		          {
		            'name' => 'sku',
		            'description' => 'tmplVar sku'
		          },
		          {
		            'name' => 'sku template',
		            'description' => 'tmplVar sku template'
		          },
		          {
		            'name' => 'weight',
		            'description' => 'tmplVar weight'
		          },
		          {
		            'name' => 'numberRegistered'
		          },
		          {
		            'name' => 'maximumAttendees'
		          },
		          {
		            'name' => 'seatsRemaining'
		          },
		          {
		            'name' => 'eventIsFull'
		          },
		          {
		            'name' => 'eventIsApproved'
		          },
		          {
		            'name' => 'startDate.human'
		          },
		          {
		            'name' => 'endDate.human'
		          },
		          {
		            'name' => 'purchase.label'
		          },
		          {
		            'name' => 'purchase.url'
		          },
		          {
		            'name' => 'purchase.message'
		          },
		          {
		            'name' => 'purchase.wantToSearch.url'
		          },
		          {
		            'name' => 'purchase.wantToContinue.url'
		          },
		          {
		            'name' => 'purchase.label'
		          }
		],
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
		variables => [
		          {
		            'name' => 'purchasesLoop',
		            'variables' => [
		                             {
		                               'name' => 'purchaseUrl'
		                             },
		                             {
		                               'name' => 'datePurchasedHuman'
		                             }
		                           ]
		          },
		          {
		            'name' => 'managePurchasesTitle'
		          }
		],
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
		variables => [
		          {
		            'name' => 'purchasesLoop',
		            'variables' => [
		                             {
		                               'name' => 'regLoop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'startDateHuman'
		                                                },
		                                                {
		                                                  'name' => 'startDateHuman'
		                                                },
		                                                {
		                                                  'name' => 'endDateHuman'
		                                                },
		                                                {
		                                                  'name' => 'startDate'
		                                                },
		                                                {
		                                                  'name' => 'endDateHuman'
		                                                },
		                                                {
		                                                  'name' => 'registrationId'
		                                                },
		                                                {
		                                                  'name' => 'title',
		                                                },
		                                                {
		                                                  'name' => 'description',
		                                                },
		                                                {
		                                                  'name' => 'price',
		                                                  'description' => 'tmplVar price'
		                                                },
		                                                {
		                                                  'name' => 'templateId'
		                                                },
		                                                {
		                                                  'name' => 'returned'
		                                                },
		                                                {
		                                                  'name' => 'approved',
		                                                  'description' => 'tmplVar approved'
		                                                },
		                                                {
		                                                  'name' => 'templateId'
		                                                },
		                                                {
		                                                  'name' => 'maximumAttendees',
		                                                },
		                                                {
		                                                  'name' => 'userId'
		                                                },
		                                                {
		                                                  'name' => 'createdByUserId'
		                                                }
		                                              ]
		                             },
		                             {
		                               'name' => 'canReturnItinerary'
		                             },
		                             {
		                               'name' => 'canAddEvents'
		                             }
		                           ]
		          },
		          {
		            'name' => 'canReturnTransaction'
		          },
		          {
		            'name' => 'viewPurchaseTitle'
		          },
		          {
		            'name' => 'canReturn'
		          },
		          {
		            'name' => 'transactionId'
		          },
		          {
		            'name' => 'appUrl'
		          }
		],
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
		variables => [
		          {
		            'name' => 'calendarJS'
		          },
		          {
		            'name' => 'basicSearch.formHeader'
		          },
		          {
		            'name' => 'advSearch.formHeader'
		          },
		          {
		            'name' => 'isAdvSearch'
		          },
		          {
		            'name' => 'search.formFooter'
		          },
		          {
		            'name' => 'search.formSubmit'
		          },
		          {
		            'name' => 'events_loop',
		            'variables' => [
		                             {
		                               'name' => 'event',
		                             },
		                             {
		                               'name' => 'title',
		                             },
		                             {
		                               'name' => 'description',
		                             },
		                             {
		                               'name' => 'price',
		                               'description' => 'tmplVar price'
		                             },
		                             {
		                               'name' => 'sku',
		                               'description' => 'tmplVar sku'
		                             },
		                             {
		                               'name' => 'sku template',
		                               'description' => 'tmplVar sku template'
		                             },
		                             {
		                               'name' => 'weight',
		                               'description' => 'tmplVar weight'
		                             },
		                             {
		                               'name' => 'numberRegistered',
		                             },
		                             {
		                               'name' => 'maximumAttendees',
		                             },
		                             {
		                               'name' => 'seatsRemaining',
		                             },
		                             {
		                               'name' => 'startDate.human',
		                             },
		                             {
		                               'name' => 'startDate',
		                             },
		                             {
		                               'name' => 'endDate.human',
		                             },
		                             {
		                               'name' => 'endDate'
		                             },
		                             {
		                               'name' => 'productId'
		                             },
		                             {
		                               'name' => 'eventIsFull',
		                             },
		                             {
		                               'name' => 'eventIsApproved',
		                             },
		                             {
		                               'name' => 'manageToolbar'
		                             },
		                             {
		                               'name' => 'purchase.label',
		                             },
		                             {
		                               'name' => 'purchase.url',
		                             }
		                           ],
		          },
		          {
		            'name' => 'paginateBar',
		          },
		          {
		            'name' => 'manageEvents.url',
		          },
		          {
		            'name' => 'manageEvents.label',
		          },
		          {
		            'name' => 'managePurchases.url',
		          },
		          {
		            'name' => 'managePurchases.label',
		          },
		          {
		            'name' => 'noSearchDialog'
		          },
		          {
		            'name' => 'addEvent.url'
		          },
		          {
		            'name' => 'addEvent.label'
		          },
		          {
		            'name' => 'canManageEvents',
		          },
		          {
		            'name' => 'message'
		          },
		          {
		            'name' => 'numberOfSearchResults'
		          },
		          {
		            'name' => 'continue.url'
		          },
		          {
		            'name' => 'continue.label'
		          },
		          {
		            'name' => 'name.label'
		          },
		          {
		            'name' => 'starts.label'
		          },
		          {
		            'name' => 'ends.label'
		          },
		          {
		            'name' => 'price.label'
		          },
		          {
		            'name' => 'seats.label'
		          },
		          {
		            'name' => 'addToBadgeMessage'
		          },
		          {
		            'name' => 'search.filters.options'
		          },
		          {
		            'name' => 'search.data.url'
		          },
		          {
		            'name' => 'ems.wobject.dir'
		          }
		],
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
