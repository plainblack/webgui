package WebGUI::i18n::English::EventsCalendar;

our $I18N = {
	'90' => {
		message => q|Default Month|,
		lastUpdated => 1038190708
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

	'80' => {
		message => q|Event Template|,
		lastUpdated => 1038190379
	},

	'2' => {
		message => q|Events Calendar|,
		lastUpdated => 1031514049
	},

	'99' => {
		message => q|Is master?|,
		lastUpdated => 1066511974
	},

	'88' => {
		message => q|Show 6 months from start.|,
		lastUpdated => 1038190632
	},

	'72' => {
		message => q|Event, Add/Edit|,
		lastUpdated => 1038887363
	},

	'82' => {
		message => q|Current.|,
		lastUpdated => 1038190803
	},

	'84' => {
		message => q|End Month|,
		lastUpdated => 1038190527
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

	'83' => {
		message => q|First in the calendar.|,
		lastUpdated => 1038190781
	},

	'75' => {
		message => q|Which do you wish to do?|,
		lastUpdated => 1031514049
	},

	'61' => {
		message => q|Events Calendar, Add/Edit|,
		lastUpdated => 1066572488
	},

	'20' => {
		message => q|Add an event.|,
		lastUpdated => 1031514049
	},

	'14' => {
		message => q|Start Date|,
		lastUpdated => 1031514049
	},

	'92' => {
		message => q|Previous Event|,
		lastUpdated => 1038202281
	},

	'89' => {
		message => q|Show 3 months from start.|,
		lastUpdated => 1038190646
	},

	'91' => {
		message => q|Add a new event.|,
		lastUpdated => 1038190852
	},

	'78' => {
		message => q|Don't delete anything, I made a mistake.|,
		lastUpdated => 1031514049
	},

	'87' => {
		message => q|Show 9 months from start.|,
		lastUpdated => 1038190626
	},

	'93' => {
		message => q|Next Event|,
		lastUpdated => 1038202290
	},

	'77' => {
		message => q|Delete this event <b>and</b> all of its recurrences.|,
		lastUpdated => 1031514049
	},

	'13' => {
		message => q|Edit Event|,
		lastUpdated => 1031514049
	},

	'96' => {
		message => q|Event Template|,
		lastUpdated => 1078568518
	},

	'85' => {
		message => q|Last in the calendar.|,
		lastUpdated => 1038190764
	},

	'94' => {
		message => q|Events Calendar Template|,
		lastUpdated => 1078520840
	},

	'97' => {
		message => q|The following is the list of template variables available in when displaying an event from the calendar.
<p/>

<b>title</b><br/>
The title of this event.
<p/>

<b>start.label</b><br/>
The translated label for the start date.
<p/>

<b>start.date</b><br/>
The date this event starts.
<p/>

<b>start.time</b><br/>
The time this event starts.
<p/>

<b>end.date</b><br/>
The date this event ends.
<p/>

<b>end.time</b><br/>
The time this event ends.
<p/>

<b>end.label</b><br/>
The translated label for the end date.
<p/>

<b>canEdit</b><br/>
A condition indicating whether the current user can edit an event.
<p/>

<b>edit.url</b><br/>
The URL to edit this event.
<p/>

<b>edit.label</b><br/>
The translated label for the edit URL.
<p/>

<b>delete.url</b><br/>
The URL to delete this event.
<p/>

<b>delete.label</b><br/>
The translated label for the delete URL.
<p/>

<b>previous.url</b><br/>
The URL to view the event before this one.
<p/>

<b>previous.label</b><br/>
The translated label for the previous URL.
<p/>

<b>next.label</b><br/>
The translated label for the next URL.
<p/>

<b>next.url</b><br/>
The URL to view the event after this one.
<p/>

<b>description</b><br/>
The description of this event.
<p/>
|,
		lastUpdated => 1099536774
	},

	'9' => {
		message => q|until|,
		lastUpdated => 1031514049
	},

	'12' => {
		message => q|Edit Events Calendar|,
		lastUpdated => 1031514049
	},

	'15' => {
		message => q|End Date|,
		lastUpdated => 1031514049
	},

	'8' => {
		message => q|Recurs every|,
		lastUpdated => 1031514049
	},

	'81' => {
		message => q|Start Month|,
		lastUpdated => 1038190442
	},

	'98' => {
		message => q|Now!|,
		lastUpdated => 1053888477
	},

	'4' => {
		message => q|Happens only once.|,
		lastUpdated => 1031514049
	},

	'73' => {
		message => q|<b>Title</b><br>
The title for this event.
<p>

<b>Description</b><br>
The activities of this event or information about where the event is to be held.
<p>

<b>Start Date</b><br>
The date and time when the event begins.
<p>

<b>End Date</b><br>
The date and time when the event ends.
<p>

<b>Recurs every</b><br>
How many times and how often the event recurs.

<p>
<b>What next?</b><br>
Select "add new event" if you'd like to add another event, otherwise select "go back to page".
This option is only available when adding an Events Calendar, not editing one.
<p>
|,
		lastUpdated => 1099549204
	},

	'19' => {
		message => q|Paginate After|,
		lastUpdated => 1031514049
	},

	'76' => {
		message => q|Delete only this event.|,
		lastUpdated => 1031514049
	},

	'86' => {
		message => q|Show 12 months from start.|,
		lastUpdated => 1038190601
	},

};

1;
