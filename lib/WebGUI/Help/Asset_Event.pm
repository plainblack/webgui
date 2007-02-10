package WebGUI::Help::Asset_Event;

our $HELP = {
	'event add/edit' => {
		title => 'add/edit title',
		body => 'add/edit body',
		isa => [
		],
		variables => [
		          {
		            'name'     => 'formHeader',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formFooter',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formTitle',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formMenuTitle',
		          },
		          {
		            'name'     => 'formLocation',
		          },
		          {
		            'name'     => 'formDescription',
		          },
		          {
		            'name'     => 'formStartDate',
		          },
		          {
		            'name'     => 'formStartTime',
		          },
		          {
		            'name'     => 'formEndDate',
		          },
		          {
		            'name'     => 'formEndTime',
		          },
		          {
		            'name'     => 'formTime',
		          },
		          {
		            'name'     => 'formRelatedLinks',
		          },
		          {
		            'name'     => 'formRecurPattern',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formRecurStart',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formRecurEnd',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formSave',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formCancel',
		          },
		          {
		            'name'     => 'formErrors',
                    variables  => [
                      {
                        'name'     => 'message',
                      },
                    ],
		          },
        ],
		related => [
		],
	},

	'event common variables' => {
		title => 'event common template variables title',
		body => 'event common template variables body',
		isa => [
		],
		variables => [
		          {
		            'name'     => 'isPublic',
		          },
		          {
		            'name'     => 'groupToView',
		          },
		          {
		            'name'     => 'startDateSecond',
		          },
		          {
		            'name'     => 'startDateMinute',
		          },
		          {
		            'name'     => 'startDateHour24',
		          },
		          {
		            'name'     => 'startDateHour',
		          },
		          {
		            'name'     => 'startDateHourM',
		          },
		          {
		            'name'     => 'startDateDayName',
		          },
		          {
		            'name'     => 'startDateDayAbbr',
		          },
		          {
		            'name'     => 'startDateDayOfMonth',
		          },
		          {
		            'name'     => 'startDateDayOfWeek',
		          },
		          {
		            'name'     => 'startDateMonthName',
		          },
		          {
		            'name'     => 'startDateMonthAbbr',
		          },
		          {
		            'name'     => 'startDateYear',
		          },
		          {
		            'name'     => 'startDateYmd',
		          },
		          {
		            'name'     => 'startDateMdy',
		          },
		          {
		            'name'     => 'startDateDmy',
		          },
		          {
		            'name'     => 'startDateHms',
		          },
		          {
		            'name'     => 'startDateEpoch',
		          },
		          {
		            'name'     => 'endDateSecond',
		          },
		          {
		            'name'     => 'endDateMinute',
		          },
		          {
		            'name'     => 'endDateHour24',
		          },
		          {
		            'name'     => 'endDateHour',
		          },
		          {
		            'name'     => 'endDateHourM',
		          },
		          {
		            'name'     => 'endDateDayName',
		          },
		          {
		            'name'     => 'endDateDayAbbr',
		          },
		          {
		            'name'     => 'endDateDayOfMonth',
		          },
		          {
		            'name'     => 'endDateDayOfWeek',
		          },
		          {
		            'name'     => 'endDateMonthName',
		          },
		          {
		            'name'     => 'endDateMonthAbbr',
		          },
		          {
		            'name'     => 'endDateYear',
		          },
		          {
		            'name'     => 'endDateYmd',
		          },
		          {
		            'name'     => 'endDateMdy',
		          },
		          {
		            'name'     => 'endDateDmy',
		          },
		          {
		            'name'     => 'endDateHms',
		          },
		          {
		            'name'     => 'endDateEpoch',
		          },
		          {
		            'name'     => 'isAllDay',
		          },
		          {
		            'name'     => 'isOneDay',
		          },
		          {
		            'name'     => 'dateSpan',
		          },
		          {
		            'name'     => 'url',
		          },
		          {
		            'name'     => 'urlDay',
		          },
		          {
		            'name'     => 'urlWeek',
		          },
		          {
		            'name'     => 'urlMonth',
		          },
		          {
		            'name'     => 'relatedLinks',
                    variables  => [
                      {
                        'name'     => 'linkUrl',
                      },
                    ],
		          },
        ],
		related => [
		],
	},

};

1;
