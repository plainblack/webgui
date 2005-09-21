package WebGUI::i18n::English::Asset_EventsCalendar;

our $I18N = {

	'61' => {
		message => q|Events Calendar, Add/Edit|,
		lastUpdated => 1066572488
	},

	'71' => {
		message => q|<p>Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also, Events Calendars on consumer sites are a great way to let your customers know what events you'll be attending and what promotions you'll be having.
<p>

<b>Start Month</b><br>
Choose the start month for your calendar.
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
</blockquote>

<p>

<b>End Month</b><br>
Choose the end month for your calendar.
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
</blockquote>
<p>
<b>Default Month</b><br>
Choose which month for this calendar to start on when a visitor comes to the page containing the calendar.

<p>
<b>Is master?</b><br>
If set to yes then this calendar will display events from all other calendars in the system.

<p>
<b>Proceed to add event?</b><br>
Leave this set to yes if you want to add events to the Events Calendar directly after creating it.

<p>
<b>Main Template</b><br>
Choose a layout for the events calendar.

<p>
<b>Event Template</b><br>
Choose a layout for the individual events within the calendars.

<p>
<b>Paginate After</b><br>
How many months of data should be shown before paginating?

<p>
<hr size="1">
<i><b>Note:</b></i> The following style is specific to the Events Calendar.

<p>
<b>.eventTitle </b><br>
The title of an individual event.

|,
		lastUpdated => 1100902948,
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
          '2' => {
                   'lastUpdated' => 1031514049,
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
		message => q|The following template variables are available for you to customize your events calendar.
<p/>
<b>addevent.url</b><br/>
The URL to add an event to the calendar.
<p/>

<b>addevent.label</b><br/>
The translated label for the add event link.
<p/>

<b>month_loop</b><br>
A loop containing all the months in the calendar.
<p>

<blockquote>

<b>daysInMonth</b><br>
The number of days in this month.
<p>

<b>day_loop</b><br>
A loop containing all the days in the month.
<p>

<blockquote>

<b>dayOfWeek</b><br>
The day number for the day in the week.
<p>

<b>day</b><br>
The day of the month.
<p>

<b>isStartOfWeek</b><br>
A boolean indicating this is the first day in the week.
<p>

<b>isEndOfWeek</b><br>
A boolean indicating this is the last day in the week.
<p>

<b>isToday</b><br>
A boolean indicating that this day is today.
<p>

<b>event_loop</b><br>
A loop containing all of the events in this day.
<p>

<blockquote>

<b>description</b><br>
The description or detail of this event.
<p>

<b>name</b><br>
The name or title of this event.
<p>

<b>start.date.human</b><br>
The human representation of the start date of this event.
<p>

<b>start.time.human</b><br>
The human representation of the start time of this event.
<p>

<b>start.date.epoch</b><br>
The epoch representation of the start date of this event.
<p>

<b>start.year</b><br>
The year this event starts.
<p>

<b>start.month</b><br>
The month this event starts.
<p>

<b>start.day</b><br>
The day this event starts.
<p>

<b>end.date.human</b><br>
The human representation of the end date of this event.
<p>

<b>end.time.human</b><br>
The human representation of the end time of this event.
<p>

<b>end.date.epoch</b><br>
The epoch representation of the end date of this event.
<p>

<b>end.year</b><br>
The year this event ends.
<p>

<b>end.month</b><br>
The month this event ends.
<p>

<b>end.day</b><br>
The day this event ends.
<p>

<b>startEndYearMatch</b><br>
A boolean indicating whether the start and end year match.
<p>

<b>startEndMonthMatch</b><br>
A boolean indicating whether the start and end month match.
<p>

<b>startEndDayMatch</b><br>
A boolean indicating whether the start and end day match.
<p>

<b>isFirstDayOfEvent</b><br>
A boolean indicating whether this day is the first day of the event.
<p>

<b>dateIsSameAsPrevious</b><br>
A boolean indicating whether the start and end date of this event are the same as the previous event's start and end date.
<p>

<b>daysInEvent</b><br>
The length of this event in days.
<p>

<b>url</b><br>
The URL to view this event in detail.
<p>



</blockquote>


<b>url</b><br>
A URL to today's events.
<p>



</blockquote>

<b>prepad_loop</b><br>
A loop containing info to prepad the days in the month before the start day.
<p>

<blockquote>
<b>count</b><br>
The day of the week for this pad.
<p>


</blockquote>

<b>postpad_loop</b><br>
A loop containing the info to postpad the days in the month after the last day.
<p>

<blockquote>
<b>count</b><br>
The day of the week for this pad.
<p>

</blockquote>

<b>month</b><br>
The name of this month.
<p>

<b>year</b><br>
The name of this year.
<p>



</blockquote>

<b>sunday.label</b><br>
A label representing "Sunday".
<p>

<b>monday.label</b><br>
A label representing "Monday".
<p>

<b>tuesday.label</b><br>
A label representing "Tuesday".
<p>

<b>wednesday.label</b><br>
A label representing "Wednesday".
<p>

<b>thursday.label</b><br>
A label representing "Thursday".
<p>

<b>friday.label</b><br>
A label representing "Friday".
<p>

<b>saturday.label</b><br>
A label representing "Saturday".
<p>


<b>sunday.label.short</b><br>
The first initial of the label for "Sunday".
<p>

<b>monday.label.short</b><br>
The first initial of the label for "Monday".
<p>

<b>tuesday.label.short</b><br>
The first initial of the label for "Tuesday".
<p>

<b>wednesday.label.short</b><br>
The first initial of the label for "Wednesday".
<p>

<b>thursday.label.short</b><br>
The first initial of the label for "Thursday".
<p>

<b>friday.label.short</b><br>
The first initial of the label for "Friday".
<p>

<b>saturday.label.short</b><br>
The first initial of the label for "Saturday".
<p>

|,
		lastUpdated => 1099548964
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
