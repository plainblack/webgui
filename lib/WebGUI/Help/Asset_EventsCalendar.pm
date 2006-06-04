package WebGUI::Help::Asset_EventsCalendar;

our $HELP = {
	'events calendar add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => 'visitor cache timeout',
                                namespace => 'Asset_EventsCalendar',
                                description => 'visitor cache timeout help',
				uiLevel => 8,
                        },
                        {
                                title => '507',
                                description => '507 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '94',
                                description => '94 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '80',
                                description => '80 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '81',
                                description => '81 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '84',
                                description => '84 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '90',
                                description => '90 description',
                                namespace => 'Asset_EventsCalendar',
                        },
                        {
                                title => '19',
                                description => '19 description',
                                namespace => 'Asset_EventsCalendar',
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'event add/edit',
				namespace => 'Asset_Event'
			},
			{
				tag => 'events calendar template',
				namespace => 'Asset_EventsCalendar'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'events calendar template' => {
		title => '94',
		body => '95',
		fields => [
		],
		variables => [
		          {
		            'name' => 'addevent.url'
		          },
		          {
		            'name' => 'addevent.label'
		          },
		          {
		            'name' => 'sunday.label'
		          },
		          {
		            'name' => 'monday.label'
		          },
		          {
		            'name' => 'tuesday.label'
		          },
		          {
		            'name' => 'wednesday.label'
		          },
		          {
		            'name' => 'thursday.label'
		          },
		          {
		            'name' => 'friday.label'
		          },
		          {
		            'name' => 'saturday.label'
		          },
		          {
		            'name' => 'sunday.label.short'
		          },
		          {
		            'name' => 'monday.label.short'
		          },
		          {
		            'name' => 'tuesday.label.short'
		          },
		          {
		            'name' => 'wednesday.label.short'
		          },
		          {
		            'name' => 'thursday.label.short'
		          },
		          {
		            'name' => 'friday.label.short'
		          },
		          {
		            'name' => 'saturday.label.short'
		          },
		          {
		            'name' => 'month_loop',
		            'variables' => [
		                             {
		                               'name' => 'daysInMonth'
		                             },
		                             {
		                               'name' => 'day_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'dayOfWeek'
		                                                },
		                                                {
		                                                  'name' => 'day'
		                                                },
		                                                {
		                                                  'name' => 'isStartOfWeek'
		                                                },
		                                                {
		                                                  'name' => 'isEndOfWeek'
		                                                },
		                                                {
		                                                  'name' => 'isToday'
		                                                },
		                                                {
		                                                  'name' => 'event_loop',
		                                                  'variables' => [
		                                                                   {
		                                                                     'name' => 'description'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'name'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'start.date.human'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'start.time.human'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'start.date.epoch'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'start.year'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'start.month'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'start.day'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'start.day.dayOfWeek'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'end.date.human'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'end.time.human'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'end.date.epoch'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'end.year'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'end.month'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'end.day'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'end.day.dayOfWeek'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'startEndYearMatch'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'startEndMonthMatch'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'startEndDayMatch'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'isFirstDayOfEvent'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'dateIsSameAsPrevious'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'daysInEvent'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'url'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'owner'
		                                                                   }
		                                                                 ]
		                                                },
		                                                {
		                                                  'name' => 'url'
		                                                }
		                                              ]
		                             },
		                             {
		                               'name' => 'prepad_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'count'
		                                                }
		                                              ]
		                             },
		                             {
		                               'name' => 'postpad_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'count'
		                                                }
		                                              ]
		                             },
		                             {
		                               'name' => 'month'
		                             },
		                             {
		                               'name' => 'year'
		                             }
		                           ]
		          }
		],
		related => [
			{
				tag => 'events calendar add/edit',
				namespace => 'Asset_EventsCalendar'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},
};

1;
