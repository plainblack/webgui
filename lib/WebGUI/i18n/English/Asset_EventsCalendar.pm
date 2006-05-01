package WebGUI::i18n::English::Asset_EventsCalendar;

our $I18N = {

	'visitor cache timeout' => {
		message => q|Visitor Cache Timeout|,
		lastUpdated => 0
		},

	'visitor cache timeout help' => {
		message => q|Since all visitors will see this asset the same way, we can cache it to increase performance. How long should we cache it?|,
		lastUpdated => 1146456063
		},

	'january' => {
		message => q|January|,
		lastUpdated => 1133711787
	},

	'61' => {
		message => q|Events Calendar, Add/Edit|,
		lastUpdated => 1066572488
	},

        '507 description' => {
                message => q|Sets the scope of the events displayed by this calendar.
<blockquote>
<dl>
<dt>Regular</dt>
<dd>This calendar will display its own events.</dd>
<dt>Global</dt>
<dd>The calendar will display events from every calendar in the site.</dd>
<dt>Master</dt>
<dd>The calendar will display events from every calendar below it in the hierarchy.</dd>
</dl>
</blockquote>|,
                lastUpdated => 1129668992,
        },

        '94 description' => {
                message => q|Choose a layout for the events calendar.|,
                lastUpdated => 1129668992,
        },

        '80 description' => {
                message => q|Choose a layout for the individual events within the calendar.|,
                lastUpdated => 1129668992,
        },

        '81 description' => {
                message => q|Choose the start month for your calendar.
<blockquote>
<dl>
<dt>First in the calendar</dt>
<dd>The calendar will start at whatever the earliest date in the calendar is.</dd>
<dt>Now!</dt>
<dd>The calendar will start on the current date and time.  It will advance and not show events that have already passed.</dd>
<dt>Current</dt>
<dd>The calendar will always start on the current month.  It is similar to "Now!" but advances from month to month.  This allows events in the current month that have passed to still be displayed.</dd>
<dt>January</dt>
<dd>The calendar will always start on January of the current year.</dd>
</dl>
</blockquote>|,
                lastUpdated => 1129668992,
        },

        '84 description' => {
                message => q|Choose the end month for your calendar.
<blockquote>
<dl>
<dt>Last in the calendar</dt>
<dd>The calendar will end at the last date in the calendar.</dd>
<dt>Show 12 months from the start</dt>
<dt>Show 9 months from the start</dt>
<dt>Show 6 months from the start</dt>
<dt>Show 3 months from the start</dt>
<dd>Show N months from the start month.  If the start month is variable, then this provides a sliding window into the events in this calendar.</dd>
<dt>Current</dt>
<dd>The calendar will always end on the current month.</dd>
</dl>
</blockquote>|,
                lastUpdated => 1129668992,
        },

        '90 description' => {
                message => q|Choose which month for this calendar to display when it is viewed.|,
                lastUpdated => 1129668992,
        },

        '19 description' => {
                message => q|How many months of data should be shown before paginating?|,
                lastUpdated => 1129668992,
        },

	'71' => {
		message => q|<p>Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also, Events Calendars on consumer sites are a great way to let your customers know what events you'll be attending and what promotions you'll be having.</p>

<p>
<hr size="1">
<i><b>Note:</b></i> The following style is specific to the Events Calendar.
</p>

<p>
<b>.eventTitle </b><br />
The title of an individual event.
</p>
|,
		lastUpdated => 1129669045,
	},


          '559' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Next'
                   },
          '503' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Personal'
                   },
          '90' => {
                    'lastUpdated' => 1038190708,
                    'message' => 'Default Month'
                  },
          '80' => {
                    'lastUpdated' => 1038190379,
                    'message' => 'Event Template'
                  },
          'assetName' => {
                   'lastUpdated' => 1128832357,
                   'message' => 'Events Calendar'
                 },
          '560' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Month'
                   },
          '506' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Tasks'
                   },
          '88' => {
                    'lastUpdated' => 1038190632,
                    'message' => 'Show 6 months from start.'
                  },
          '500' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'May Manage This Calendar'
                   },
          '82' => {
                    'lastUpdated' => 1038190803,
                    'message' => 'Current.'
                  },
          '84' => {
                    'lastUpdated' => 1038190527,
                    'message' => 'End Month'
                  },
          '83' => {
                    'lastUpdated' => 1038190781,
                    'message' => 'First in the calendar.'
                  },
          '20' => {
                    'lastUpdated' => 1031514049,
                    'message' => 'Add an event.'
                  },
          '501' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Calendar Type'
                   },
          '89' => {
                    'lastUpdated' => 1038190646,
                    'message' => 'Show 3 months from start.'
                  },
          '504' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Agenda'
                   },
          '502' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Regular'
                   },
          '505' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Resource'
                   },
          '87' => {
                    'lastUpdated' => 1038190626,
                    'message' => 'Show 9 months from start.'
                  },
          '508' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Regular'
                   },
          '85' => {
                    'lastUpdated' => 1038190764,
                    'message' => 'Last in the calendar.'
                  },
          '94' => {
                    'lastUpdated' => 1078520840,
                    'message' => 'Events Calendar Template'
                  },

	'95' => {
		message => q|<p>The following template variables are available for you to customize your events calendar.
</p>
<p>
<b>addevent.url</b><br />
The URL to add an event to the calendar.
</p>

<p>
<b>addevent.label</b><br />
The translated label for the add event link.
</p>

<p>
<b>sunday.label</b><br />
A label representing "Sunday".
</p>

<p>
<b>monday.label</b><br />
A label representing "Monday".
</p>

<p>
<b>tuesday.label</b><br />
A label representing "Tuesday".
</p>

<p>
<b>wednesday.label</b><br />
A label representing "Wednesday".
</p>

<p>
<b>thursday.label</b><br />
A label representing "Thursday".
</p>

<p>
<b>friday.label</b><br />
A label representing "Friday".
</p>

<p>
<b>saturday.label</b><br />
A label representing "Saturday".
</p>

<p>
<b>sunday.label.short</b><br />
The first initial of the label for "Sunday".
</p>

<p>
<b>monday.label.short</b><br />
The first initial of the label for "Monday".
</p>

<p>
<b>tuesday.label.short</b><br />
The first initial of the label for "Tuesday".
</p>

<p>
<b>wednesday.label.short</b><br />
The first initial of the label for "Wednesday".
</p>

<p>
<b>thursday.label.short</b><br />
The first initial of the label for "Thursday".
</p>

<p>
<b>friday.label.short</b><br />
The first initial of the label for "Friday".
</p>

<p>
<b>saturday.label.short</b><br />
The first initial of the label for "Saturday".
</p>

<p>
<b>month_loop</b><br />
A loop containing all the months in the calendar.
</p>

<blockquote>

<p>
<b>daysInMonth</b><br />
The number of days in this month.
</p>

<p>
<b>day_loop</b><br />
A loop containing all the days in the month.
</p>

<blockquote>

<p>
<b>dayOfWeek</b><br />
The day number for the day in the week.
</p>

<p>
<b>day</b><br />
The day of the month.
</p>

<p>
<b>isStartOfWeek</b><br />
A boolean indicating this is the first day in the week.
</p>

<p>
<b>isEndOfWeek</b><br />
A boolean indicating this is the last day in the week.
</p>

<p>
<b>isToday</b><br />
A boolean indicating that this day is today.
</p>

<p>
<b>event_loop</b><br />
A loop containing all of the events in this day.
</p>

<blockquote>

<p>
<b>description</b><br />
The description or detail of this event.
</p>

<p>
<b>name</b><br />
The name or title of this event.
</p>

<p>
<b>start.date.human</b><br />
The human representation of the start date of this event.
</p>

<p>
<b>start.time.human</b><br />
The human representation of the start time of this event.
</p>

<p>
<b>start.date.epoch</b><br />
The epoch representation of the start date of this event.
</p>

<p>
<b>start.year</b><br />
The 4-digit year this event starts.
</p>

<p>
<b>start.month</b><br />
The name of the month this event starts, internationalized.
</p>

<p>
<b>start.day</b><br />
The day this event starts.
</p>

<p>
<b>start.day.dayOfWeek</b><br />
The name of the day of the week this event starts, internationalized.
</p>

<p>
<b>end.date.human</b><br />
The human representation of the end date of this event.
</p>

<p>
<b>end.time.human</b><br />
The human representation of the end time of this event.
</p>

<p>
<b>end.date.epoch</b><br />
The epoch representation of the end date of this event.
</p>

<p>
<b>end.year</b><br />
The 4-digit year this event ends.
</p>

<p>
<b>end.month</b><br />
The name of the month this event ends, internationalized.
</p>

<p>
<b>end.day</b><br />
The day this event ends.
</p>

<p>
<b>end.day.dayOfWeek</b><br />
The name of the day of the week this event ends, internationalized.
</p>

<p>
<b>startEndYearMatch</b><br />
A boolean indicating whether the start and end year match.
</p>

<p>
<b>startEndMonthMatch</b><br />
A boolean indicating whether the start and end month match.
</p>

<p>
<b>startEndDayMatch</b><br />
A boolean indicating whether the start and end day match.
</p>

<p>
<b>isFirstDayOfEvent</b><br />
A boolean indicating whether this day is the first day of the event.
</p>

<p>
<b>dateIsSameAsPrevious</b><br />
A boolean indicating whether the start and end date of this event are the same as the previous event's start and end date.
</p>

<p>
<b>daysInEvent</b><br />
The length of this event in days.
</p>

<p>
<b>url</b><br />
The URL to view this event in detail.
</p>

</blockquote>

<p>
<b>url</b><br />
A URL to today's events.
</p>

</blockquote>

<p>
<b>prepad_loop</b><br />
A loop containing info to prepad the days in the month before the start day.
</p>

<blockquote>

<p>
<b>count</b><br />
The day of the week for this pad.
</p>

</blockquote>

<p>
<b>postpad_loop</b><br />
A loop containing the info to postpad the days in the month after the last day.
</p>

<blockquote>

<p>
<b>count</b><br />
The day of the week for this pad.
</p>

</blockquote>

<p>
<b>month</b><br />
The name of this month, internationalized.
</p>

<p>
<b>year</b><br />
The 4 digit year in the current month of the month_loop.
</p>

</blockquote>

|,
		lastUpdated => 1129765329
	},

          '509' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Master'
                   },
          '558' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Previous'
                   },
          '561' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Months'
                   },
          '12' => {
                    'lastUpdated' => 1031514049,
                    'message' => 'Edit Events Calendar'
                  },
          '81' => {
                    'lastUpdated' => 1038190442,
                    'message' => 'Start Month'
                  },
          '98' => {
                    'lastUpdated' => 1053888477,
                    'message' => 'Now!'
                  },
          '510' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Global'
                   },
          '86' => {
                    'lastUpdated' => 1038190601,
                    'message' => 'Show 12 months from start.'
                  },
          '19' => {
                    'lastUpdated' => 1031514049,
                    'message' => 'Paginate After'
                  },
          '507' => {
                     'lastUpdated' => 1108397891,
                     'message' => 'Calendar Scope'
                   }
        };

1;
